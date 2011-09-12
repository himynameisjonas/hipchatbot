class Twss < Bot::Command
  # monitor_all

  def self.description
    "That's what she said!"
  end

  require 'twss'
  TWSS.threshold = 8.0
  def self.respond(message)
    message.send("That's what she said!") if TWSS(message.message)
  end
end
