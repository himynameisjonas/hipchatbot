class Say < Bot::Command
  respond_to "say", "whisper", "sing"
  
  def self.respond(message)
    case message.command
    when "whisper"
      system "say", "-vwhisper", message.message
    when "sing"
      system "say", "-vcello", message.message  
    when "say"
      system "say", message.message  
    end
  end

  def self.description
    "Say it with words"
  end
end
