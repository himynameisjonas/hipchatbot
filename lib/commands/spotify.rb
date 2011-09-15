class Spotify < Bot::Command
  respond_to "next", "prev", "play", "pause", "playing", "track", "album", "queue"
  require 'appscript'
  require 'json'

  QUEUE = []

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
      QUEUE << search_for_track(message.message)
      message.send "added song to queue"
    when "album"
      return message.send "@#{message.from} please add a search query" unless message.message
      message.send "currently broken'"
      play_href search_for_album message.message
      hide_spotify
      message.send("Now playing: #{current_track}")
    when "queue"
      message.send(QUEUE.inspect)
    end
  end

  def self.lower_spotify
    100.downto(30) do |i|
      set_volume i
    end
    sleep 0.2
    yield
    30.upto(100) do |i|
      set_volume i
    end
  end

  def self.play_from_queue
    unless QUEUE.empty?
      sleep Appscript::app("Spotify").current_track.duration.get-Appscript::app("Spotify").player_position.get
      play_href QUEUE.shift
      play_from_queue
    else
      sleep 3
      play_from_queue
    end
  end

  def self.start_queue
    Thread.new do
      play_from_queue
    end
  end

  start_queue

  private

  def self.set_volume(volume)
    Appscript::app("Spotify").sound_volume.set volume
  end

  def self.current_track
    current_track = Appscript::app("Spotify").current_track
    "#{current_track.artist.get} - #{current_track.name.get}"
  end

  def self.hide_spotify
    Appscript::app("Finder").processes["Spotify"].visible.set(false)
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
