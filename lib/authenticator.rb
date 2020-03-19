# frozen_string_literal: true

# Class definition for an authentication layer of the slacker app
# This class retrieves secret keys and oauth codes and relays get
# and post requests to the API adding the authorisation token as
# they are passed.
class Authenticator
  require 'launchy'
  require 'cgi'
  require 'json'
  require 'httparty'
  require_relative 'encryption'
  require_relative 'local_server'

  def initialize(url, client_id, client_secret, scope, user_scope)
    # scope left as general
    @url = url
    @user_scope = user_scope ? 'user_scope=' : 'scope='
    @scope = @user_scope + scope
    @redirect_uri = 'http://localhost:3000/oauth2/callback'
    @server = LocalServer.new
    # private
    @client_id = client_id
    @client_secret = client_secret
    @token = ''
    @code = ''
    @secure = Encryption.new
  end

  # Opens a browser window for OAuth2 authentication in Slack.
  # Needs error handling, returns encrypted user session key on success
  def authenticate
    if @code == ''
      Launchy.open(client)
      getter = LocalServer.new
      @code = CGI.parse getter.response
      @code = @code['GET /oauth2/callback?code'][0]
    end
    self
  end

  def new_session
    if @token == ''
      response = @server.post(token_client)
      response = JSON.parse response.body
      @token = response['authed_user']['access_token']
    end
    self
  end

  def get(url)
    payload = url + "&token=#{@token}"
    @server.get(payload)
  end

  def post(url)
    payload = url + "&token=#{@token}"
    @server.post(payload)
  end

  private

  def encrypt(unencrypted_data)
    secure.encrypt unencrypted_data
  end

  def decrypt(encrypted_data)
    secure.decrypt encrypted_data
  end

  def validate
    # Retrieve the X-Slack-Request-Timestamp header on the HTTP request,
    # and the body of the request.
    # Concatenate the version number, the timestamp,
    # and the body of the request to form a basestring.
    # Use a colon as the delimiter between the three elements.
    # For example, v0:123456789:command=/weather&text=94070.
    # The version number right now is always v0.
    # With the help of HMAC SHA256 implemented in your favorite programming,
    # hash the above basestring, using the Slack Signing Secret as the key.
    # Compare this computed signature to the X-Slack-Signature header on the request.
  end

  # Builds the client OAuth2 request to send to slack, request opens in browser
  def client
    "#{@url}oauth/v2/authorize?#{@scope}&client_id=#{@client_id}&redirect_uri=#{@redirect_uri}"
  end

  def token_client
    "#{@url}api/oauth.v2.access?client_id=#{@client_id}&client_secret=#{@client_secret}&code=#{@code}&redirect_uri=#{@redirect_uri}"
  end
end
