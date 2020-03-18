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
    response = HTTParty.post(url)
    puts 'Please check your internet connection' unless response.code == 200
    response.body
  end

  # Print html response to browser
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
