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
      :message => text,
      :muc => muc
    })
    Bot::MONITORS.each {|command| command.respond(message)} unless nick == Bot::Config.basic.nick
    return unless text =~ /^#{salutation}:*\s+(.+)$/i or text =~ /^!(.+)$/
    command, *command_message = $1.split(" ")
    message = Message.new({
      :from => firstname = nick.split(/ /).first,
      :command => command,
      :message => command_message.join(" "),
      :muc => muc
    })
    process(message)
  end

  def process(message)
    warn "command: #{message.from}> #{message.command}"
    Bot::Command.delegate_command(message)
  end

end