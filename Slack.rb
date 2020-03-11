class Slack
  require_relative 'Authenticator'
  
  attr_accessor :active_chat, :message
  
  @@LOCAL_HOST = 'http://localhost:3000/oauth2/callback'
  @@URI_HEAD = "https://"
  @@SLACK_URI = 'slack.com/'
  @@URL = @@URI_HEAD + @@SLACK_URI
  @@USER_SCOPE = true
  @@SCOPE = 'channels:read,chat:write,users:read,users:read.email'
  @@CLIENT_ID = '930069515525.977879044658'

  def initialize token=false
    @user = Authenticator.new @@URL, @@LOCAL_HOST, @@CLIENT_ID, @@SCOPE, @@USER_SCOPE
    @active_chat = ''
    # @name = @user.name
    @message = ''
    @team = 'ca-m0120/'
    # @state = Change to random code to be passed back by slack to authenticate response, later revision to increase security
    self
  end

  # def name
  #   @name
  # end

  def login
    @user.client.token
    self
  end

  def message msg
    HTTParty.POST("#{@@URI_HEAD + @team + @@SLACK_URI}api/chat.postMessage?token=xoxp-#{@user.send()}&as_user=true&channel=#{@active_chat}&text=#{msg}")
  end

  def active_chat
    @active_chat
  end

  def active_chat=(id)
    @active_chat = id
  end
  
  def contact_list

  end

  def conversations
    p response = @user.send( @@URI_HEAD + @team + @@SLACK_URI + "/conversations.list?" )

    response = CGI.parse response

    p response
    # GET
    # conversations.list

    # Expected response
    # application/x-www-form-urlencoded

    # channels.info
    

    # @chat_id = response.
  end

  def send
    # POST /api/chat.postMessage
    # Content-type: application/json
    # Authorization: Bearer xoxp-xxxxxxxxx-xxxx
    # {"channel":"C061EG9SL","text":"I hope the tour went well, Mr. Wonka.","attachments":[{"text":"Who wins the lifetime supply of chocolate?","fallback":"You could be telling the computer exactly what it can do with a lifetime supply of chocolate.","color":"#3AA3E3","attachment_type":"default","callback_id":"select_simple_1234","actions":[{"name":"winners_list","text":"Who should win?","type":"select","data_source":"users"}]}]}


    # Format json
    # text: "USER TEXT HERE"
    # mrkdwn: true/false (fr markdown formatting)

  end

  def delete
    # https://slack.com/api/chat.delete
    # POST  

  # POST /api/conversations.create
  # Content-type: application/json
  # Authorization: Bearer xoxp-xxxxxxxxx-xxxx
  # {"name":"something-urgent"}



    # https://app.slack.com/client/TTC21F5FF/
  end

  def create_contact_file

  end

  # Slack user token string: "xoxp-"
  # Workspace access tokens: "xoxa-2" refresh "xoxr"
end

# session = Slack.new
