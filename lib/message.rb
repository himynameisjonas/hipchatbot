class Bot::Message
  attr_accessor :from, :command, :message, :muc

  def initialize args
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def respond(message)
    muc.send Jabber::Message.new(muc.room, message)
  end
end