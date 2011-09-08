task :run do
  require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'bot'))
  settings = {
      :server   => "",
      :rooms    => "",
      :room     => "",
      :nick     => "",
      :jid      => "",
      :password => "",
      :debug    => Logger.new(STDOUT),
  }

  Bot.new(settings).connect.run
end
