require 'spec_helper'

describe Bot::Message do
  describe ".new" do
    it "sets the instance variables" do
      from = "from"
      command = "command"
      message = "message"
      muc_or_client = "client"
      one_to_one = "one to one"
      bot_msg =Bot::Message.new({
        :from => from,
        :command => command,
        :message => message,
        :muc_or_client => muc_or_client,
        :one_to_one => one_to_one
        })
        bot_msg.from = from
        bot_msg.command = command
        bot_msg.message = message
        bot_msg.muc_or_client = muc_or_client
        bot_msg.one_to_one = one_to_one
    end
  end
  describe "#send" do
    before(:each) do
      @jabber_message = double('message').as_null_object
      Jabber::Message.stub(:new).and_return(@jabber_message)
      @muc = double().as_null_object
    end
    it "calls send on muc_or_client with Jabber::Message" do
      @muc.should_receive(:send).with @jabber_message
      message = Bot::Message.new(:muc_or_client => @muc)
      message.send("hello")
    end
    it "call Jabber::Message.new with room if muc is set" do
      @muc.should_receive :room
      message = Bot::Message.new(:muc_or_client => @muc)
      message.send("hello")
    end
    it "do not call room on muc_or_client if one_to_one is set" do
      @muc.should_not_receive :room
      message = Bot::Message.new(:muc_or_client => @muc, :one_to_one => @muc)
      message.send("hello")
    end
    it "sets message type to :chat" do
      @jabber_message.should_receive(:'type=').with :chat
      Bot::Message.new(:muc_or_client => @muc).send("hello")
    end
  end
end