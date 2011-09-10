class SoundFx < Bot::Command
  respond_to "easy", "friday", "rimshot", "sad", "yeah"

  def self.description
    "Awesome audio fx!"
  end

  def self.respond(message)
    case message.command
    when "easy"
      play_file "easy.mp3"
    when "friday"
     Time.now.wday == 5 ? play_file("friday.mp3") : message.send("Today != Friday")
    when "rimshot"
      play_file "rimshot.mp3"
    when "sad"
      play_file "sadtrombone.mp3"
    when "yeah"
      play_file "yeah.mp3"
    end
  end

  private

  def self.play_file(file_name)
    system "afplay", File.expand_path(File.join(__FILE__, "..", "..", "..", "extras", file_name))
  end
end
