# frozen_string_literal: true

# This class spins up servers temporarilly to retrieve requests from oauth sessions
# It also handles post and get http requests with the HTTParty gem.
class LocalServer
  require 'socket'
  require 'httparty'

  def initialize; end

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
    timeout = 0.1
    begin
      puts timeout
    response = HTTParty.post(url, timeout: timeout)
    # unless response.code == 200
    #   raise response, 'Problems with Slack.com try again later'
    #   # Handle exceptions
    #   # parsed_response
    # end
    # rescue => e
    #   e.message
    #   e.backtrace.inspect
    #   if response.code == 400
    #     puts 'Authentication failed, your session may have expired.'
    #     puts 'Opening browser to reauthenticate...'
        
    #   end
      # p JSON.parse(e.body)['parsed_response']
    rescue Net::ReadTimeout
      puts 'Your internet connection appears to be slow. Trying again...'
      if timeout < 60
        timeout += 20
        retry
      else
        puts 'Check your internet connection before you retry.'
        false
      end
    else
      response
    end
  end

  # Print html response to browser
  # Put template response page external to code
  def page(client)
    client = client
    client.puts('HTTP/1.1 200 OK')
    client.puts('Content-Type: text/html; charset=UTF-8')
    client.puts('')
    client.puts('<!DOCTYPE HTML>')
    client.puts('<html>')
    client.puts('<head onload="function()">')
    client.puts('<title>slacker</title>')
    client.puts('</head>')
    client.puts('<body>')
    client.puts('<h1>DONT PANIC: Return to your terminal session...</h1>')
    client.puts('</body>')
    client.puts('</html>')
    # client.puts("<script>
    #               function() {
    #               open(location, '_self').close();
    #               }, 2000);
    #             </script>")
    self
  end
end

# instance = LocalServer.new
