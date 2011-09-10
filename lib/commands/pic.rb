class Pic < Bot::Command
  respond_to "pic"
  require 'open-uri'
  require 'json'

  def self.description
    "Post a picture from search string"
  end

  def self.respond(message)
    begin
      json = JSON.parse(open("http://api.search.live.net/json.aspx?AppId=#{Bot::Config.live_id}&Query=#{CGI.escape "\"#{message.message}\""}&Sources=Image&Version=2.0&Adult=Moderate&Image.Count=1").read)
      image = json["SearchResponse"]["Image"]["Results"][0]["Thumbnail"]["Url"]
      message.send("#{image}#.jpg")
    rescue NoMethodError
      message.send("sorry, no matches")
    end
  end
end
