class Ping < Bot::Command
  respond_to "ping"
  
  def self.respond(message)
    message.send("#{message.from}: Pong #{message.message}")
  end

  def self.description
    "Pong!"
  end
end
