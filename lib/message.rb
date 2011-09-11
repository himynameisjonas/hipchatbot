class Bot::Message
  attr_accessor :from, :command, :message, :muc_or_client, :one_to_one

  def initialize args
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def send(message)
    to = one_to_one || muc_or_client.room
    jabber_message = Jabber::Message.new(to, message)
    jabber_message.type = :chat
    muc_or_client.send jabber_message
  end
end