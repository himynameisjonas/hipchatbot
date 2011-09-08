class Ping < Bot::Command
  respond_to "ping"
  
  def self.respond(command, firstname, bot, muc)
    puts "ping. respond!"
    bot.respond("#{firstname}: Pong!", muc)
  end

  def self.description
    "Pong!"
  end
end
