# frozen_string_literal: true

# require 'pry'
require_relative 'authenticator'

# This class handles all the interactions with slack and sends them to the
# LocalServer class via the Authenticator class.
# The instance of this class in the main code allows communication with the
# Slack API by compiling application/x-www-form-urlencoded style http requests.
# The Authentication class returns the responses to these in a meaningful format
# to print to the terminal.
class Slack
  attr_reader :conversation, :conversation_name, :channels, :users

  def initialize
    @URI_HEAD = 'https://'
    @SLACK_URI = 'slack.com/'
    @URL = @URI_HEAD + @SLACK_URI
    @USER_SCOPE = true
    @SCOPE = 'channels:read,channels:history,groups:history,im:history,
              mpim:history,users:read,chat:write,'
    # DUDE MAKE A HASH OUT OF ALL OF THESE INSTANCE VARIABLES... FREEZE IT IF YOU MUST BUT CLEAN UP THIS MESS!
    # Load encrypted keys from .config.yml
    config = YAML.load_file(__dir__ + '/../' + '.keys.yml')
    @CLIENT_ID = config[:CLIENT_ID]
    @CLIENT_SECRET = config[:CLIENT_SECRET]
    @EXIT = { name: '<Exit>', value: false }
    @CHANNELS = { name: '#Channels', value: :ch }
    @PRIVATE_MSG = { name: '-Private messages', value: :pm }
    @user = Authenticator.new @URL, @CLIENT_ID, @CLIENT_SECRET, @SCOPE, @USER_SCOPE
    @conversation = :ch
    @conversation_name = ''
    @channels = []
    @users = []
    @conversations = []
    @message = ''
    # @state = Change to random code to be passed back by slack to authenticate
    # response, later revision to increase security
  end

  def login
    @user_id ? response = @user.new_session : response = @user.authenticate.new_session
    return false unless response

    @user_id = response['authed_user']['id']
    @team = response['team']['id']
    @team_name = response['team']['name']
    @channels[0] = load_channels
    @users[0] = load_users
    @channels.each { |hash| @conversations << hash }
    @users.each { |hash| @conversations << hash }
    self
  end

  def message(text)
    return false if text == ''

    payload = "#{@URL}api/chat.postMessage?channel=#{@conversation}&text=#{text}"
    response = @user.post(payload)
    response = JSON.parse(response.body)
    print 'Message undelivered: check your internet connection' unless response['ok']
    true
  end

  # Message history: to be added in later revision.
  # def history
  #   now = Time.now
  #   time = now - 864000000
  #   p time.to_f
  #   payload = "#{@URL}api/conversations.history?channel=#{@conversation}&limit=5&inclusive=true&oldest=#{time}"
  #   response = @user.get(payload)
  #   response = JSON.parse response
  #   p response
  #   response['messages'].each do |chan|
  #     history << { id: chan['user'], text: chan['id'], time: chan['ts'] }
  #   end
  # end

  def load_channels
    @channels = []
    @channels << @PRIVATE_MSG
    @channels << @EXIT
    payload = "#{@URL}api/conversations.list?"
    response = @user.get(payload)
    response = JSON.parse response
    response['channels'].each do |chan|
      @channels << { name: '#' + chan['name'], value: chan['id'] }
    end
    @channels
  end

  def load_users
    @users = []
    @users << @CHANNELS
    @users << @EXIT
    payload = "#{@URL}api/users.list?"
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
  end
end
