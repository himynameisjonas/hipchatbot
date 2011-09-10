class Stats < Bot::Command
  respond_to "online"
  require 'json'
  CHARTBEAT_URL = "http://api.chartbeat.com"

  def self.description
    "Stats"
  end

  def self.respond(message)
    case message.command
    when "online"
      message.send "Online right now: #{online_right_now}"
    end
  end

  private

  def self.online_right_now
    require 'open-uri'
    doc = open "#{CHARTBEAT_URL}/quickstats?host=#{Bot::Config.chartbeat.domain}&apikey=#{Bot::Config.chartbeat.key}"
    json = JSON.parse doc.read
    json["people"]
  end
end