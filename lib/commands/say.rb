class Say < Bot::Command
  respond_to "say", "whisper", "sing"

  def self.description
    "Say it with words"
  end

  def self.respond(message)
    case message.command
    when "whisper"
      Spotify.lower_spotify do
        system "say", "-vwhisper", message.message
      end
    when "sing"
      Spotify.lower_spotify do
        system "say", "-vcello", message.message
      end
    when "say"
      Spotify.lower_spotify do
        system "say", message.message
      end
    end
  end
end
