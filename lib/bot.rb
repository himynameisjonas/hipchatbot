require 'rubygems'
require "bundler/setup"
require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'

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
    client.jid.resource = "bot"
    self.mucs   = []
    if Bot::Config.basic.debug
      Jabber.logger = Logger.new(STDOUT)
      Jabber.debug = true
    end
  end

  def run
    connect
    join_rooms
    monitor_rooms
    monitor_one_to_one
    warn "running"
    Thread.stop
  end

  private

  def connect
    warn "connecting...."
    client.connect
    client.auth(Bot::Config.basic.password)
    client.send(Jabber::Presence.new.set_type(:available))
    client.on_exception do
      warn "Connection lost, trying to reconnect in 10 seconds"
      sleep 10
      reconnect
    end
  rescue => e
    warn "connection failed, trying again in 10 seconds"
    sleep 10
    reconnect
  end

  def reconnect
    begin
      mucs.map(&:exit) unless musc.empty?
      client.close!
    rescue => e
      warn "failed to close"
    end
    begin
      self.client = Jabber::Client.new(Bot::Config.basic.jid)
      connect
      join_rooms
      monitor_rooms
      monitor_one_to_one
    rescue => e
      warn "connection failed, trying again in 10 seconds"
      sleep 10
      reconnect
    end
  end

  def join_rooms
    self.mucs = Bot::Config.basic.rooms.map do |room|
      muc = Jabber::MUC::SimpleMUCClient.new(client).join(room + '/' + Bot::Config.basic.nick)
      muc.send Jabber::Message.new muc.room, "/me is online and waiting for commands"
      muc
    end
  end

  def monitor_rooms
    mucs.each do |muc|
      muc.on_message do |time, nick, text|
        begin
          handle_message nick, text, muc
        rescue => e
          warn "exception: #{e.inspect}"
        end
      end
    end
  end

  def monitor_one_to_one
    client.add_message_callback do |message|
      begin
        if message.type == :chat and message.body and message.from != Bot::Config.basic.jid
          handle_message message.from.to_s, message.body, client, message.from
        end
      rescue => e
        warn "exception: #{e.inspect}"
      end
    end
  end

  def handle_message(nick, text, muc_or_client, one_to_one = nil)
    salutation = Bot::Config.basic.nick.split(/\s+/).first
    message = Message.new({
      :from => nick.split(/ /).first,
      :message => text,
      :muc_or_client => muc_or_client,
      :one_to_one => one_to_one
    })
    process_monitors(message) unless nick == Bot::Config.basic.nick
    return unless text =~ /^#{salutation}:*\s+(.+)$/i or text =~ /^!(.+)$/
    message.command, message.message = $1.split(" ", 2)
    process_commands(message)
  end

  def process_commands(message)
    warn "command: #{message.muc_or_client.jid.to_s.split("@").first} > #{message.from} > #{message.command} #{message.message}"
    Bot::Command.delegate_command(message)
  end

  def process_monitors(message)
    Bot::MONITORS.each do |monitor|
      monitor.respond(message)
    end
  end
end