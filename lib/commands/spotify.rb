class Spotify < Bot::Command
  respond_to "next", "prev", "play", "pause", "playing", "track", "album", "volume"
  require 'appscript'
  require 'json'

  def self.description
    "Controll Spotify"
  end

  def self.respond(message)
    case message.command
    when "next"
      Appscript::app("Spotify").next_track
      message.send("Now playing: #{current_track}")
    when "prev"
      Appscript::app("Spotify").previous_track 
      sleep 0.1
      Appscript::app("Spotify").previous_track 
      message.send("Now playing: #{current_track}")
    when "pause"
      Appscript::app("Spotify").pause
      message.send("Stoped playing")
    when "play"
      Appscript::app("Spotify").play
      message.send("Started playing: #{current_track}")
    when "playing"
      message.send("Playing: #{current_track}")
    when "track"
      return message.send "@#{message.from} please add a search query" unless message.message
      play_href search_for_track message.message
      hide_spotify
      message.send("Now playing: #{current_track}")
    when "album"
      return message.send "@#{message.from} please add a search query" unless message.message
      message.send "currently broken'"
      play_href search_for_album message.message
      hide_spotify
      message.send("Now playing: #{current_track}")
    when "volume"
      if validate_message(message.message)
        adjust_volume(message.message)
      else
        message.send("Please use only + or -")
      end
    end
  end

  def self.validate_message(up_or_down)
    up_or_down =~ /^[\+]+$/ or up_or_down =~ /^[\-]+$/
  end

  def self.adjust_volume(up_or_down)
    amount = up_or_down.length * 10
    new_volume = up_or_down[0,1] == "+" ? get_volume + amount : get_volume - amount
    set_volume new_volume
  end

  def self.get_volume
    Appscript::app("Spotify").sound_volume.get
  end

  def self.set_volume(volume)
    Appscript::app("Spotify").sound_volume.set volume
  end

  def self.lower_spotify
    current_volume = get_volume
    set_volume [30, current_volume].min
    yield
    set_volume current_volume
  end

  def self.current_track
    current_track = Appscript::app("Spotify").current_track
    "#{current_track.artist.get} - #{current_track.name.get}"
  end

  def self.hide_spotify
    system "osascript", "-e", "tell application \"Finder\" to set visible of process \"Spotify\" to false"
  end

  def self.play_href(href)
    system "open", href
  end

  def self.search_for_track(query)
    response = JSON.parse open("http://ws.spotify.com/search/1/track.json?q=#{CGI.escape query}").read
    track = check_availability(response["tracks"]).first
    track["href"]
  end

  def self.search_for_album(query)
    response = JSON.parse open("http://ws.spotify.com/search/1/album.json?q=#{CGI.escape query}").read
    track = check_availability(response["albums"]).first
    track["href"]
  end

  def self.check_availability(results)
    results.select do |result|
      if result.has_key? "album"
        result["album"]["availability"]["territories"].include?("SE")
      else
        result["availability"]["territories"].include?("SE")
      end
    end
  end
end
