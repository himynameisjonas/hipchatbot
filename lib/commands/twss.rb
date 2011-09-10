class Twss < Bot::Command
  monitor_all
  
  require 'twss'
  TWSS.threshold = 3.0
  def self.respond(message)
    message.send("That's what she said!") if TWSS(message.message)
  end

  def self.description
    "That's what she said!"
  end
end
