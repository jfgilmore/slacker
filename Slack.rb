class Slack
  require_relative 'Authenticator'
  require 'httparty'
  
  attr_accessor :active_chat, :message
  
  @@LOCAL_HOST = 'http://localhost:3000/oauth2/callback'
  @@URI_HEAD = "https://"
  @@SLACK_URI = 'slack.com/'
  @@URL = @@URI_HEAD + @@SLACK_URI
  @@USER_SCOPE = true
  @@SCOPE = 'channels:read,channels:history,users:read,chat:write,'#users:read.email
  @@CLIENT_ID = 
  @@CLIENT_SECRET = 
  @@EXIT = {name: "Exit", value: false}
  @@CHANNELS = {name: "Channels", value: :ch}
  @@PRIVATE_MSG = {name: "Private messages", value: :pm, disabled: '(coming soon...)'}

  def initialize
    @user = Authenticator.new @@URL, @@LOCAL_HOST, @@CLIENT_ID, @@CLIENT_SECRET, @@SCOPE, @@USER_SCOPE
    @channel = :ch
    @channel_name = ''
    @channels = []
    @message = ''
    # @state = Change to random code to be passed back by slack to authenticate response, later revision to increase security
    self
  end

  def login
    if @user_id
    p "0"
      @user.new_session
    else
    p "1"
      @user.authenticate.new_session
    end
    p "2"
    @user_id = @user.user_id
    @team = @user.team
    @team_name = @user.team_name
    return self
  end

  def message text
    if text == ''
      false
    else
      # json = { "channel": @channel,
      #             "text": text
      #           }
      payload = ("#{@@URL}api/chat.postMessage?channel=#{@channel}&text=#{text}")
      response = @user.post(payload)
      response = JSON.parse response
      p response
      true
      # POST /api/chat.postMessage
      # Content-type: application/json
      # Authorization: Bearer xoxp-xxxxxxxxx-xxxx
      # {"channel":"C061EG9SL","text":"I hope the tour went well, Mr. Wonka.","attachments":[{"text":"Who wins the lifetime supply of chocolate?","fallback":"You could be telling the computer exactly what it can do with a lifetime supply of chocolate.","color":"#3AA3E3","attachment_type":"default","callback_id":"select_simple_1234","actions":[{"name":"winners_list","text":"Who should win?","type":"select","data_source":"users"}]}]}
    end
  end

  def conversations
    if @channels == []
      response = ''
      payload = ("#{@@URL}api/conversations.list?")
      response = @user.get(payload)
      response = JSON.parse response
      response["channels"].each do |chan|
        @channels << {name: "#" + chan["name"], value: chan["id"]}
      end
      @channels << @@PRIVATE_MSG
      @channels << @@EXIT
    end
    @channels
  end

  def history
    response = @user.get("#{@@URL}api/conversations.history?channel=#{@channel}&limit=5")
    response = @user.get(payload)
    response = JSON.parse response
    response["messages"].each do |chan|
      history << {id: chan["user"], text: chan["id"], :time chan["ts"]}
    end
  end

  def personal_messages
    if @channels == []
      response = ''
      payload = ("#{@@URL}api/conversations.open")
      response = @user.get(payload)
      response = JSON.parse response
      response["channels"].each do |chan|
        @channels << {name: "#" + chan["name"], value: chan["id"]}
      end
      @channels << @@CHANNELS
      @channels << @@EXIT
    end
    @channels
  end

  def channel
      @channel
  end

  def channel_name
    @channel_name
  end

  def channel=(id)
    @channels.each do |chan|
      if id == chan[:value]
        @channel_name = chan[:name]
        @channel = chan[:value]
      else
        @channel = id
      end
    end
    self
  end
end
