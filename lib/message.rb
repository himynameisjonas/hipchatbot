require 'hipchat-api'

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

  def send_html(message)
    raise "This command only works in a room" if one_to_one
    room_id = Bot::Config.basic.rooms.select{|room| room.jid.split("@").first == muc_or_client.room}.first.room_id
    response = api.rooms_message(room_id, Bot::Config.basic.nick, message, 0, "random")
    if response.code != 200
      raise response.parsed_response["error"]["message"]
    end
  end

  def api
    @api ||= HipChat::API.new(Bot::Config.basic.api_token)
  end
end