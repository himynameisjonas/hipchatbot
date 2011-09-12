require 'spec_helper'

describe Bot do
  describe "#new" do
    it "set up a connection" do
      bot = Bot.new
      bot.connection.should be_kind_of Bot::Connection
    end
  end
  describe "#run" do
    it "calls setup methods and stop the thread" do
      Bot::Connection.any_instance.should_receive :connect
      Bot::Connection.any_instance.should_receive :join_rooms
      Bot.any_instance.should_receive :monitor_rooms
      Bot.any_instance.should_receive :monitor_one_to_one
      Thread.should_receive :stop
      Bot.new.run
    end
  end
end