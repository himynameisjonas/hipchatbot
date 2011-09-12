class System < Bot::Command
  respond_to "selfupdate", "reboot"

  def self.description
    "Controll the bot"
  end

  def self.respond(message)
    case message.command
    when "selfupdate"
      system("git fetch")
      diff = `git log --decorate --left-right --graph --cherry-pick --oneline master...origin/master`
      if diff.empty?
        message.send("No updates found. No need to reboot!")
      else
        message.send("Applying updates")
        message.send(diff)
        system("git pull --rebase")
        reboot(message)
      end
    when "reboot"
      reboot(message)
    end
  end

  private

  def self.reboot(message)
    message.send("Rebooting...")
    exec("rake run")
  end
end
