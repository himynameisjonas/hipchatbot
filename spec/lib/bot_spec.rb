require 'spec_helper'

describe Bot do
  before(:each) do
    @client = double('client').as_null_object
    Jabber::Client.stub(:new).and_return(@client)
    Thread.stub :stop
  end
  
  describe "#new" do
    it "set up a client with 'bot' as resource" do
      Jabber::Client.unstub(:new)
      bot = Bot.new
      bot.client.should be_kind_of Jabber::Client
      bot.client.jid.resource.should eql("bot")
    end
  end
  describe "#run" do
    it "calls setup methods and stop the thread" do
      Bot.any_instance.should_receive :connect
      Bot.any_instance.should_receive :join_rooms
      Bot.any_instance.should_receive :monitor_rooms
      Bot.any_instance.should_receive :monitor_one_to_one
      Thread.should_receive :stop
      Bot.new.run
    end
  end
end