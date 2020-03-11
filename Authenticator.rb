# frozen_string_literal: true

class Authenticator
  require_relative 'LocalServer'
  require 'symmetric-encryption'
  require 'launchy'
  require 'cgi'

  def initialize(url, redirect_uri, client_id, scope, user_scope)
    # scope left as general
    @url = url
    @user_scope = if user_scope
               'user_scope='
             else
               'scope='
             end
    @scope = @user_scope + scope
    @redirect_uri = redirect_uri
    @client_id = 
    @user_url = 'config/.slacker.yml'
    config_url = 'config/symmetric-encryption.yml'

    # Start Symmetric-Encryption
    begin
      SymmetricEncryption.load! File.expand_path(config_url, __dir__)
    rescue StandardError
      p 'generating config files...'
      `symmetric-encryption --generate --app-name slacker.yml --environments "development"`
      `touch #{File.expand_path(@user_url, __dir__)}`
      `chmod -R 0400 config`
      SymmetricEncryption.load! File.expand_path(config_url, __dir__)
    rescue StandardError
      puts 'FATAL ERROR! encryption, retrty, or raise a bug request.'
      exit
    end
    
    
    # If a token is present decrypt it for use, otherwise generate a new token when called
    @token = if self.secret[2]
               true
             else
               false
            end
    # @name = if self.secret[1]
    #           self.secret[1]
    #         else
    #           ''
    #         end
  end

  # def name
  #   unless @name
  #     self.send(@url + "api/users.profile.get?" + )
  #   end
  #   @name
  # end

  # Builds the client OAuth2 request to send to slack, request opens in browser
  def client
    @client = "#{@url}/oauth/v2/authorize?#{@scope}&client_id=#{@client_id}&redirect_uri=#{@redirect_uri}"
    self
  end

  # Opens a browser window for OAuth2 authentication in Slack.
  # Needs error handling, returns encrypted user session key on success
  def token
    unless @token
      Launchy.open(@client.to_s)
      getter = LocalServer.new
      token = CGI.parse getter.response
      p token = token['GET /oauth2/callback?code'][0]
      # self.name
      self.secret = token
      @token = true
    end
    self.secret[1]
  end

  # Appends user token to url for API request
  def send url
    Launchy.open (url + "token=xoxp-" + self.secret[3])
  end

  private

  def secret
    @secret = ''
    output = []
    x = 0
    SymmetricEncryption::Reader.open File.expand_path(@user_url, __dir__) do |file|
      file.each_line do |line|
        output[x] = line
        x += 1
      end
    end
    output
  end

  def secret=(token)
    SymmetricEncryption::Writer.open(File.expand_path(@user_url, __dir__)) do |file|
      file.write @client_id
      # file.write name
      file.write token
    end
  end
end
