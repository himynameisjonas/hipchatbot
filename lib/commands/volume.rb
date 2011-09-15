class Volume < Bot::Command
  respond_to "volume", "vol"
  require 'appscript'
  require 'osax'

  def self.description
    "Controll Volume with + or -"
  end

  def self.respond(message)
    if validate_message(message.message)
      adjust_volume(message.message)
      message.send("new: #{get_volume}")
    else
      message.send("Please use only + or -")
    end
  end

  private

  def self.validate_message(up_or_down)
    up_or_down =~ /^[\+]+$/ or up_or_down =~ /^[\-]+$/
  end

  def self.adjust_volume(up_or_down)
    amount = up_or_down.length * 7
    new_volume = up_or_down[0,1] == "+" ? get_volume + amount : get_volume - amount
    set_volume [[new_volume,0].max, 100].min
  end

  def self.get_volume
    OSAX.osax.get_volume_settings[:output_volume]
  end

  def self.set_volume(volume)
    system("osascript -e 'set volume output volume #{volume}'")
  end
end
