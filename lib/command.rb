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

  def self.delegate_command(command, firstname, bot, muc)
    puts "delegate"
    puts "#{Bot::COMMANDS[command].nil?}"
    return false if Bot::COMMANDS[command].nil?
    Bot::COMMANDS[command].respond(command, firstname, bot, muc)
  end
end
