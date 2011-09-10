class Spotify < Bot::Command
  respond_to "next", "prev", "play", "pause", "track"
  require 'appscript'
  
  def self.respond(message)
    case message.command
    when "next"
      Appscript::app("Spotify").next_track
      current_track = Appscript::app("Spotify").current_track
      message.send("Now playing: #{current_track.name.get} - #{current_track.artist.get}")
    when "prev"
      Appscript::app("Spotify").previous_track 
      sleep 0.1
      Appscript::app("Spotify").previous_track 
      current_track = Appscript::app("Spotify").current_track
      message.send("Now playing: #{current_track.name.get} - #{current_track.artist.get}")
    when "pause"
      Appscript::app("Spotify").pause
      message.send("Stoped playing")
    when "play"
      Appscript::app("Spotify").play
      current_track = Appscript::app("Spotify").current_track
      message.send("Started playing: #{current_track.name.get} - #{current_track.artist.get}")
    when "track"
      current_track = Appscript::app("Spotify").current_track
      message.send("Playing: #{current_track.name.get} - #{current_track.artist.get}")
    end
  end

  def self.description
    "Controll Spotify"
  end
end
