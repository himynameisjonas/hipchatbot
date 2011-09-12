class Bot::Connection
  attr_reader :client, :mucs

  def initialize
    @client = Jabber::Client.new(Bot::Config.basic.jid)
    @client.jid.resource = "bot"
    @mucs = []
  end

  def connect
    warn "connecting...."
    @client.connect
    @client.auth(Bot::Config.basic.password)
    @client.send(Jabber::Presence.new.set_type(:available))
    @client.on_exception do
      warn "Connection lost, trying to reconnect in 10 seconds"
      sleep 10
      reconnect
    end
  rescue => e
    warn "connection failed, trying again in 10 seconds"
    sleep 10
    reconnect
  end

  def reconnect
    close_connection
    connect
  rescue => e
    warn "connection failed, trying again in 10 seconds"
    sleep 10
    reconnect
  end

  def join_rooms
    @mucs = Bot::Config.basic.rooms.map do |room|
      muc = Jabber::MUC::SimpleMUCClient.new(@client).join(room + '/' + Bot::Config.basic.nick)
      muc.send Jabber::Message.new muc.room, "/me is online and waiting for commands"
      muc
    end
  end

  def close_connections
    begin
      @mucs.each{|m| m.exit } unless @mucs.empty?
    rescue => e
      warn "failed closing/no musc to close"
    end
    begin
      client.close!
    rescue => e
      warn "failed to close client connection"
    end
  end

end