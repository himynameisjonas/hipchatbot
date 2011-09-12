require 'spec_helper'

describe Bot::Connection do
  describe ".new" do
    it "should set up a Jabber::Client with resource = bot" do
      connection = Bot::Connection.new
      connection.client.should be_kind_of Jabber::Client
      connection.client.jid.resource.should eql "bot"
    end
  end
  describe "#connect" do
    it "calls connect methods on Jabber::Client" do
      @client = double("client").as_null_object
      @client.should_receive :connect
      @client.should_receive :auth
      @client.should_receive :send
      @client.should_receive :on_exception
      Jabber::Client.stub(:new).and_return @client
      Bot::Connection.new.connect
    end
  end
  describe "#reconnect" do
    it "should close connection and reconnect" do
      Bot::Connection.any_instance.should_receive :close_connection
      Bot::Connection.any_instance.should_receive :connect
      Bot::Connection.new.reconnect
    end
  end
  describe "#join_rooms" do
    it "should set up a Jabber::MUC::SimpleMUCClient for each room in config" do
      client = double("client").as_null_object
      Jabber::Client.stub(:new).and_return client
      Bot::Config.stub_chain(:basic, :jid)
      Bot::Config.stub_chain(:basic, :nick).and_return("username")
      Bot::Config.stub_chain(:basic, :rooms).and_return(["foo", "bar"])
      muc_client = double("muc_client")
      muc_client.should_receive(:join).with("foo/username").and_return(muc_client)
      muc_client.should_receive(:join).with("bar/username").and_return(muc_client)
      muc_client.should_receive(:send).twice
      muc_client.should_receive(:room).twice.and_return(:room_name)
      Jabber::MUC::SimpleMUCClient.stub(:new).with(client).twice.and_return(muc_client)
      Bot::Connection.new.join_rooms
    end
  end
  describe "#close_connections" do
    it "calls exit on all mucs" do
      muc1 = double("muc")
      muc2 = double("muc")
      muc1.should_receive :exit
      muc2.should_receive :exit
      connection = Bot::Connection.new
      connection.instance_variable_set(:@mucs, [muc1, muc2])
      connection.close_connections
    end
    it "calls close! on the client" do
      @client = double("client").as_null_object
      @client.should_receive :close!
      Jabber::Client.stub(:new).and_return @client
      Bot::Connection.new.close_connections
    end
  end
end