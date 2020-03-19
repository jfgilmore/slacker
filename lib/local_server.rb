# frozen_string_literal: true

# This class spins up servers temporarilly to retrieve requests from oauth sessions
# It also handles post and get http requests with the HTTParty gem.
class LocalServer
  require 'launchy'
  require 'socket'
  require 'httparty'

  def initialize; end

  # Opens session in default browser
  def launch(url)
    Launchy.open(url) do |exception|
      puts "Attempted to open Slack for authentication and failed because:
      #{exception}"
    end
  end

  # Get response then close session
  # Spin up server on request
  def response
    @server = TCPServer.open('localhost', 3000)
    @response = ''
    loop do
      client = @server.accept
      @response = client.gets
      page(client)
      client.close
      return @response
    end
  end

  def get(url)
    response = HTTParty.get(url)
    puts 'Please check your internet connection' unless response.code == 200
    response.body
  end

  def post(url)
    timeout = 20
    begin
      response = HTTParty.post(url, timeout: timeout)
    rescue Net::ReadTimeout
      puts 'Your internet connection appears to be slow. Trying again...'
      if timeout < 40
        timeout += 20
        retry
      else
        puts "It looks like you're having some connectivity isues 😞"
        false
      end
    rescue SocketError
      tries = handle_html_error(response, tries)
      retry
    else
      response
    end
  end

  # Print html response to browser
  # Put template response page external to code
  def page(client)
    file = File.read(__dir__ + '/../docs/' + 'login_response.html')
    client = client
    client.puts('HTTP/1.1 200 OK')
    client.puts('Content-Type: text/html; charset=UTF-8')
    client.puts('')
    client.puts(file.to_s)
    self
  end

  def handle_html_error(response, tries)
    case response.code
    when 200
      tries = 0
      return tries
    when 404
      puts '404: Alright, we have a serious problem here!'
    when 500...600
      puts 'Somethings up with Slack, you may have to wait a while...\n' +
           response.code.to_s
      sleep(4)
    else
      puts 'It appears, we\'re in the stone age, check your internet connection'
      sleep(20)
    end
    # If repeated errors
    if tries == 3
      puts "It's just not your day, try again sometime later."
      sleep(3)
      puts 'Perhaps drop us a line? Let us know what\'s going wrong.'
      sleep(3)
      mail_to 'djsounddog@gmail.com', 'Slacker keep thowing an error:' +
              response.code.to_s + '\n' + response.message.to_s + '\n\nThanks,' +
              'Concerned Individual', subject: 'These errors are making me crazy'
    else
      times
    end
  end
end

# instance = LocalServer.new
