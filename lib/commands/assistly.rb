class Assistly < Bot::Command
  respond_to "support"
  require 'oauth'
  require 'json'

  def self.description
    "try 'support q'"
  end

  def self.respond(message)
    case message.command
    when "support"
      case message.message
      when "q"
        cases = cases_asssigned_to_group("tech-support")
        message.send "Available cases: #{cases["total"]}"
        message.send cases["results"].map{|c| "* #{c['case']['subject']}\n"}.join("")
      end
    end
  end

  private

  def self.cases_asssigned_to_group(group)
    JSON.parse(access_token.get("/api/v1/cases.json?status=open,new&assigned_group=#{group}").body)
  end
  
  def self.access_token
    @@access_token ||= OAuth::AccessToken.from_hash(
      OAuth::Consumer.new(
        Bot::Config.assistly.consumer,
        Bot::Config.assistly.consumer_secret,
        :site => Bot::Config.assistly.site,
        :scheme => :header
      ),
      :oauth_token => Bot::Config.assistly.oauth_token,
      :oauth_token_secret => Bot::Config.assistly.oauth_token_secret
    )
  end

end