task :run do
  require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'bot'))
  config = YAML.load File.read("config.yml")
  Bot.new(config).run
end