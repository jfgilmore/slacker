require_relative 'LocalServer'
require 'symmetric-encryption'

class SlackAuthenticator
require 'launchy'
require 'cgi'

  def initialize url, redirect_uri, token=''
    @USER_SCOPE = 'channels:read,chat:write,users:read,users:read.email'
    @CLIENT_ID = '930069515525.977879044658'
    @url = url
    @redirect_uri = redirect_uri
    config_url = "config/symmetric-encryption.yml"
    
    begin
      SymmetricEncryption.load! File.expand_path(config_url, __dir__)
    rescue
      p 'generating config files'
      `symmetric-encryption --generate --app-name slacker.yml --environments "development"`
      `chmod -R 0400 config`
      SymmetricEncryption.load! File.expand_path(config_url, __dir__)
    rescue
      puts "FATAL ERROR: encryption"
      exit
    end

    @token = SymmetricEncryption.decrypt token
  end

  def client
    @client = "#{@url}/oauth/v2/authorize?user_scope=#{@USER_SCOPE}&client_id=#{@CLIENT_ID}&redirect_uri=#{@redirect_uri}"
    return self
  end

  def token
    if @token == ''
    Launchy.open( "#{@client}" )
    getter = LocalServer.new
    @token = CGI.parse getter.response
    end
    @token = SymmetricEncryption.encrypt @token["GET /oauth2/callback?code"][0]
    return @token
  end

end

user = SlackAuthenticator.new 'http://slack.com', 'http://localhost:3000/oauth2/callback'

user.client.token
p user.token




# token = client.auth_code.get_token('authorization_code_value', :redirect_uri => 'http://localhost:8080/oauth2/callback', :headers => {'Authorization' => 'Basic some_password'})
# response = token.get('/api/resource', :params => { 'query_foo' => 'bar' })
# response.class.name
# # => OAuth2::Response

# Launchy.open( "#{client}")

# client1 = HTTParty.post("https://slack.com/oauth/v2/authorize?user_scope=channels:read,identity.team,chat:write,users.profile:read,users:read,users:read.email&client_id=930069515525.977879044658")

# identity_scope = "https://slack.com/oauth/v2/authorize?user_scope=identity.basic,identity.email,identity.team&client_id=930069515525.977879044658"


# user_scope

# Launchy.open user_scope