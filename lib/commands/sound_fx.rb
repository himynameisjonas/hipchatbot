class SoundFx < Bot::Command
  respond_to "easy", "friday", "rimshot", "sad", "yeah"

  def self.description
    "Awesome audio fx!"
  end

  def self.respond(message)
    case message.command
    when "easy"
      Spotify.lower_spotify do
        play_file "easy.mp3"
      end
    when "friday"
      if Time.now.wday == 5
        Spotify.lower_spotify do
          play_file("friday.mp3")
        end
      else
        message.send("Today != (rebeccablack)")
      end
    when "rimshot"
      Spotify.lower_spotify do
        play_file "rimshot.mp3"
      end
    when "sad"
      Spotify.lower_spotify do
        play_file "sadtrombone.mp3"
      end
    when "yeah"
      Spotify.lower_spotify do
        play_file "yeah.mp3"
      end
    end
  end

  private

  def self.play_file(file_name)
    system "afplay", File.expand_path(File.join(__FILE__, "..", "..", "..", "extras", file_name))
  end
end
