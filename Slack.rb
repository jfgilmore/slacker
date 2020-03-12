# frozen_string_literal: true

class Slack
  require_relative 'authenticator'
  require 'httparty'
  attr_reader :conversation, :conversation_name, :channels, :users

  @@LOCAL_HOST = 'http://localhost:3000/oauth2/callback'
  @@URI_HEAD = 'https://'
  @@SLACK_URI = 'slack.com/'
  @@URL = @@URI_HEAD + @@SLACK_URI
  @@USER_SCOPE = true
  @@SCOPE = 'channels:read,channels:history,groups:history,im:history,mpim:history,users:read,chat:write,' # users:read.email
  @@CLIENT_ID = 
  @@CLIENT_SECRET = 
  @@EXIT = { name: '<Exit>', value: false }
  @@CHANNELS = { name: '#Channels', value: :ch }
  @@PRIVATE_MSG = { name: '-Private messages', value: :pm}

  def initialize
    @user = Authenticator.new @@URL, @@LOCAL_HOST, @@CLIENT_ID, @@CLIENT_SECRET, @@SCOPE, @@USER_SCOPE
    @conversation = :ch
    @conversation_name = ''
    @channels = []
    @users = []
    @conversations = []
    @message = ''
    # @state = Change to random code to be passed back by slack to authenticate response, later revision to increase security
    self
  end

  def login
    if @user_id
      @user.new_session
    else
      @user.authenticate.new_session
    end
    @user_id = @user.user_id
    @team = @user.team
    @team_name = @user.team_name
    @channels[0] = self.load_channels
    @users[0] = self.load_users
    @channels.each do |hash|
      @conversations << hash
    end
    @users.each do |hash|
      @conversations << hash
    end
    self
  end

  def message(text)
    if text == ''
      false
    else
      payload = "#{@@URL}api/chat.postMessage?channel=#{@conversation}&text=#{text}"
      response = @user.post(payload)
      response = JSON.parse response
      true
    end
  end
  
  # Message history: to be added in later revision.
  # def history
  #   now = Time.now
  #   time = now - 864000000
  #   p time.to_f
  #   payload = "#{@@URL}api/conversations.history?channel=#{@conversation}&limit=5&inclusive=true&oldest=#{time}"
  #   response = @user.get(payload)
  #   response = JSON.parse response
  #   p response
  #   response['messages'].each do |chan|
  #     history << { id: chan['user'], text: chan['id'], time: chan['ts'] }
  #   end
  # end

  def load_channels
    @channels = []
    @channels << @@PRIVATE_MSG
    @channels << @@EXIT
    payload = "#{@@URL}api/conversations.list?"
    response = @user.get(payload)
    response = JSON.parse response
    response['channels'].each do |chan|
      @channels << { name: '#' + chan['name'], value: chan['id'] }
    end
    @channels
  end


  def load_users
    @users = []
    @users << @@CHANNELS
    @users << @@EXIT
    payload = "#{@@URL}api/users.list?"
    response = @user.get(payload)
    response = JSON.parse response
    response['members'].each do |chan|
      @users << { name: '-' + chan['name'], value: chan['id'] }
    end
    @users
  end

  def conversation=(id)
    @conversations.each do |chan|
      if id == chan[:value]
        @conversation_name = chan[:name]
        @conversation = chan[:value]
      else
        @conversation = id
      end
    end
    self
  end
end
