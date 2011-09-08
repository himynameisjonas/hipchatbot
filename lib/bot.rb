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
  
  attr_accessor :config, :client, :mucs
  
  COMMANDS = {}
  
  Dir.glob("lib/commands/**/*.rb").each do |file|
    require File.expand_path(File.join(File.dirname(__FILE__), "..", file))
  end

  def initialize(config)
    self.config = config
    self.client = Jabber::Client.new(config[:jid])
    self.mucs   = []
    if Jabber.logger = config[:debug]
      Jabber.debug = true
    end
    self
  end

  def connect
    client.connect
    client.auth(config[:password])
    client.send(Jabber::Presence.new.set_type(:available))

    salutation = config[:nick].split(/\s+/).first

    config[:rooms].each do |room|
      mucs << Jabber::MUC::SimpleMUCClient.new(client).join(room + '/' + config[:nick])
    end

    mucs.each do |muc|
      muc.on_message do |time, nick, text|
        next unless text =~ /^#{salutation}:*\s+(.+)$/i or text =~ /^!(.+)$/
        begin
          process(nick, $1, muc)
        rescue => e
          warn "exception: #{e.inspect}"
        end
      end
    end
    self
  end

  def process(from, command, muc)
    warn "command: #{from}> #{command}"
    firstname = from.split(/ /).first

    # case command
    #   # Speech
    # when /^(hey|hi|hello|sup|what's up|what's happenin(|g)|yo)(|[!?])$/ then
    #   respond "Yoyoyo #{firstname}, what it is?", muc
    # 
    # when /I love you/i then
    #   respond "Awww, I love you too #{firstname}!", muc
    # 
    # when /you're the best/i then
    #   respond "Well shit, #{firstname}, don't I know it!", muc
    # 
    #   # Commands
    # when /^echo\s+([^\s].*)$/ then
    #   respond "#{from}: #{$1}", muc
    # 
    # when /^weather\s+([^\s]+)/ then
    #   query = 'select item from weather.forecast where location = "' + $1 + '"'
    #   uri   = 'http://query.yahooapis.com/v1/public/yql?format=json&q=' + CGI.escape(query)
    #   data  = JSON.parse open(uri).read
    # 
    #   item      = data["query"]["results"]["channel"]["item"]
    #   title     = item["title"]
    #   condition = item["condition"]
    # 
    #   response = title
    #   response += " are " + condition['temp'] + ' degrees and ' + condition['text'] if condition
    # 
    #   respond response, muc
    # 
    # else
    #   respond "#{from}: what?", muc
    # end
    
    Bot::Command.delegate_command(command, firstname, self, muc)
  end

  def respond(msg, muc)
    muc.send Jabber::Message.new(muc.room, msg)
  end

  def run
    warn "running"
    loop { sleep 1 }
  end

  def self.run(config)
    bot = Bot.new(config).connect
    bot.run
  end
end