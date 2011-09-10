class Selfupdate < Bot::Command
  respond_to "selfupdate"

  def self.description
    "Do a 'git pull' and restart Flower"
  end

  def self.respond(message)
    system("git fetch")
    diff = `git log --decorate --left-right --graph --cherry-pick --oneline master...origin/master`
    if diff.empty?
      message.send("No updates found. No need to reboot!")
    else
      message.send("Applying updates and rebooting:")
      message.send(diff)
      system("git pull --rebase")
      exec("rake run &")
    end
  end
end
