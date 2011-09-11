require 'spec_helper'

describe Bot::Config do
  describe ".method_missing" do
    it "should map methods to keys in config constant" do
      Bot::Config::CONFIG.test = "foo"
      Bot::Config.test.should eql "foo"
    end
  end
end