class Pic < Bot::Command
  respond_to "pic"
  require 'open-uri'
  require 'json'
  require 'httparty'

  IMAGE_CACHE = {}

  def self.description
    "Post a picture from search string"
  end

  def self.respond(message)
    begin
      image = IMAGE_CACHE.has_key?(message.message) ? IMAGE_CACHE[message.message] : upload_to_imgur(search_bing(message.message), message.message)
      message.send_html("<a href='#{image["upload"]["links"]["original"]}'><img src='#{image["upload"]["links"]["large_thumbnail"]}'></a>")
    rescue NoMethodError
      message.send("sorry, no matches")
    end
  end

  def self.search_bing(query)
    json = JSON.parse(open("http://api.search.live.net/json.aspx?AppId=#{Bot::Config.live_id}&Query=#{CGI.escape "\"#{query}\""}&Sources=Image&Version=2.0&Adult=Moderate&Image.Count=1").read)
    json["SearchResponse"]["Image"]["Results"][0]["MediaUrl"]
  end

  def self.upload_to_imgur(url, query)
    return IMAGE_CACHE[query] if IMAGE_CACHE.has_key? query
    response = HTTParty.post("http://api.imgur.com/2/upload.json", :query => {:key => Bot::Config.imgur_api_key, :image => url}).parsed_response
    IMAGE_CACHE[query] = response
    response
  end
end