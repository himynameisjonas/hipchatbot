require 'spec_helper'

describe Bot::Command do
  describe ".respond_to" do
    it "should add self to the hash, with command as key" do
      Bot::COMMANDS.keys.should_not include("test")

      class TestCommand < Bot::Command
        respond_to "test"
      end

      Bot::COMMANDS.should include({"test" => TestCommand})
    end

    it "should not override already defined command if called twice" do
      class FirstTestCommand < Bot::Command
        respond_to "dup_test"
      end
      class SecondTestCommand < Bot::Command
        respond_to "dup_test"
      end

      Bot::COMMANDS["dup_test"].should == FirstTestCommand
    end
  end

  describe ".monitor_all" do
    it "should add self to the array" do
      expect {
        class TestCommand < Bot::Command
          monitor_all
        end
      }.to change{Bot::MONITORS.size}.by(1)
    end
  end

  describe ".delegate_command" do
    it "should return if command is not defined" do
      Bot::COMMANDS["foo"].should be_nil
      Bot::Command.delegate_command(Bot::Message.new(:command => "foo")).should be_false
    end

    it "should call class defined in command constant" do
      class TestCommand < Bot::Command
        respond_to "delegate_me"
        def self.respond(*args)
          @responded = true
        end
      end

      Bot::Command.delegate_command(Bot::Message.new(:command => "delegate_me")).should be_true
      TestCommand.instance_variable_get("@responded").should be_true
    end
  end
end