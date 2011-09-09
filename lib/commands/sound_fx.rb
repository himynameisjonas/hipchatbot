class SoundFx < Bot::Command
  respond_to "easy", "rimshot", "sad", "yeah"

  def self.respond(message)
    case message.command
    when "easy"
      play_file "easy.mp3"
    when "rimshot"
      play_file "rimshot.mp3"
    when "sad"
      play_file "sadtrombone.mp3"
    when "yeah"
      play_file "yeah.mp3"
    end
  end

  def self.description
    "Awesome audio fx!"
  end

  private

  def self.play_file(file_name)
    system "afplay", File.expand_path(File.join(__FILE__, "..", "..", "..", "extras", file_name))
  end
end
