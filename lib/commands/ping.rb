class Ping < Bot::Command
  respond_to "ping"
  
  def self.respond(message)
    warn "ping. respond!"
    message.respond("#{message.from}: Pong #{message.message}")
  end

  def self.description
    "Pong!"
  end
end
