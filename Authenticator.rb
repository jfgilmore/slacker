
class Authenticator
  require_relative 'LocalServer'
  require 'launchy'
  require 'cgi'
  require 'json'
  require 'httparty'

  def initialize(url, redirect_uri, client_id, client_secret, scope, user_scope)
    # scope left as general
    @url = url
    @user_scope = if user_scope
                    'user_scope='
                  else
                    'scope='
                  end
    @scope = @user_scope + scope
    @redirect_uri = redirect_uri
    @server = LocalServer.new
    
    @user_id = ''
    @team = ''
    @team_name = ''

    # private
    @client_id = client_id
    @client_secret = client_secret
    @token = ''
    @code = ''
  end

  # Opens a browser window for OAuth2 authentication in Slack.
  # Needs error handling, returns encrypted user session key on success
  def authenticate
    if @code == ''
      Launchy.open(self.client)
      getter = LocalServer.new
      @code = CGI.parse getter.response
      @code = @code['GET /oauth2/callback?code'][0]
    end
    self
  end

  def new_session
    if @token == ''
      response = @server.post(self.token_client)
      response = JSON.parse response
      @token = response["authed_user"]["access_token"]
      @user_id = response["authed_user"]["id"]
      @team = response["team"]["id"]
      @team_name = response["team"]["name"]
    end
    self
  end

  def get url
    payload = url + "&token=#{@token}"
    @server.get(payload)
  end

  def post url
    payload = url + "&token=#{@token}"
    @server.post(payload)
  end

  def user_id
    @user_id
  end

  def team
    @team
  end
  
  def team_name
    @team_name
  end 

  private
  # Builds the client OAuth2 request to send to slack, request opens in browser
  def client
    "#{@url}oauth/v2/authorize?#{@scope}&client_id=#{@client_id}&redirect_uri=#{@redirect_uri}"
  end

  def token_client
    ("#{@url}api/oauth.v2.access?client_id=#{@client_id}&client_secret=#{@client_secret}&code=#{@code}&redirect_uri=#{@redirect_uri}")
  end
end
