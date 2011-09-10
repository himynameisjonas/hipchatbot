require 'rubygems'
require "bundler/setup"
require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'
require 'open-uri'
require 'cgi'
require 'json'
require 'lib/muc-patch'

class Bot
  require 'lib/command'
  require 'lib/message'
  require 'lib/config'
  attr_accessor :client, :mucs
  
  COMMANDS = {}
  MONITORS = []
  
  Dir.glob("lib/commands/**/*.rb").each do |file|
    require File.expand_path(File.join(File.dirname(__FILE__), "..", file))
  end

  def initialize
    self.client = Jabber::Client.new(Bot::Config.basic.jid)
    self.mucs   = []
    if Bot::Config.basic.debug
      Jabber.logger = Logger.new(STDOUT)
      Jabber.debug = true
    end
    self
  end

  def run
    connect
    join_rooms
    warn "running"
    loop { sleep 1 }
  end

  private

  def connect
    client.connect
    client.auth(Bot::Config.basic.password)
    client.send(Jabber::Presence.new.set_type(:available))
  end

  def join_rooms
    Bot::Config.basic.rooms.each do |room|
      muc = Jabber::MUC::SimpleMUCClient.new(client).join(room + '/' + Bot::Config.basic.nick)
      muc.on_message do |time, nick, text|
        begin
          handle_message nick, text, muc
        rescue => e
          warn "exception: #{e.inspect}"
        end
      end
      mucs << muc
    end
  end

  def handle_message(nick, text, muc)
    salutation = Bot::Config.basic.nick.split(/\s+/).first
    message = Message.new({
      :from => nick.split(/ /).first,
      :message => text,
      :muc => muc
    })
    process_monitors(message) unless nick == Bot::Config.basic.nick
    return unless text =~ /^#{salutation}:*\s+(.+)$/i or text =~ /^!(.+)$/
    message.command, message.message = $1.split(" ", 2)
    process_commands(message)
  end

  def process_commands(message)
    warn "command: #{message.from}> #{message.command}"
    Bot::Command.delegate_command(message)
  end

  def process_monitors(message)
    Bot::MONITORS.each do |monitor|
      monitor.respond(message)
    end
  end
end