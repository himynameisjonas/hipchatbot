class Pic < Bot::Command
  respond_to "pic"
  
  def self.respond(message)
    begin
      json = JSON.parse(open("http://api.search.live.net/json.aspx?AppId=8F2285BC4C3351C997BE97DCBAAC449E79B5947A&Query=#{CGI.escape "\"#{message.message}\""}&Sources=Image&Version=2.0&Adult=Moderate&Image.Count=1").read)
      image = json["SearchResponse"]["Image"]["Results"][0]["Thumbnail"]["Url"]
      message.send("#{image}#.jpg")
    rescue NoMethodError
      message.send("sorry, no matches")
    end
  end

  def self.description
    "Post a picture from search string"
  end
end
