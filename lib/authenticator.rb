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

  attr_reader :team, :team_name, :user_id

  def initialize( url, client_id, client_secret, scope, user_scope)
    # scope left as general
    @url = url
    @user_scope = user_scope ? 'user_scope=' : 'scope='
    @scope = @user_scope + scope
    @redirect_uri = 'http://localhost:3000/oauth2/callback'
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
      Launchy.open(client)
      getter = LocalServer.new
      @code = CGI.parse getter.response
      @code = @code['GET /oauth2/callback?code'][0]
    end
    self
  end

  def new_session
    if @token == ''
      p token_client
      response = @server.post(token_client)
      response = JSON.parse response
      @token = response['authed_user']['access_token']
      @user_id = response['authed_user']['id']
      @team = response['team']['id']
      @team_name = response['team']['name']
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

  def encrypt unencrypted_data
    secure.encrypt unencrypted_data
  end

  def decrypt encrypted_data
    secure.decrypt encrypted_data
  end

  # Builds the client OAuth2 request to send to slack, request opens in browser
  def client
    "#{@url}oauth/v2/authorize?#{@scope}&client_id=#{@client_id}&redirect_uri=#{@redirect_uri}"
  end

  def token_client
    "#{@url}api/oauth.v2.access?client_id=#{@client_id}&client_secret=#{@client_secret}&code=#{@code}&redirect_uri=#{@redirect_uri}"
  end
end
