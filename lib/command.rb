class Bot::Command
  def self.respond_to(*commands)
    commands.each do |command|
      if Bot::COMMANDS[command]
        warn "Command already defined: #{command}"
      else
        Bot::COMMANDS[command] = self
      end
    end
  end

  def self.monitor_all
    Bot::MONITORS << self
  end

  def self.delegate_command(message)
    warn "delegates command #{message.command}"
    return false if Bot::COMMANDS[message.command].nil?
    Thread.new do
      Bot::COMMANDS[message.command].respond(message)
    end
  end
end
