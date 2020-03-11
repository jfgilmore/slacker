class LocalServer
  require 'socket'

  # Spin up server on request
  def initialize
    @server  = TCPServer.open('localhost', 3000)
    @response = ''
  end

  # Get response then close session
  def response
    loop {
      client = @server.accept
      self.page(client)
      @response = client.gets
      client.close
      return @response
    }
  end

  # Print html response to browser
  def page client
      client = client
      client.puts("HTTP/1.1 200 OK");
      client.puts("Content-Type: text/html; charset=UTF-8");
      client.puts("");
      client.puts("<!DOCTYPE HTML>");
      client.puts("<html>");
      client.puts("<head onload=\"function()\">");
      client.puts("<title>slacker</title>");
      client.puts("</head>");
      client.puts("<body>");
      client.puts("<h1>DONT PANIC: Return to your terminal session...</h1>")
      client.puts("</body>");
      client.puts("</html>");
      # client.puts("<script>
      #               function() {
      #               open(location, '_self').close();
      #               }, 2000);
      #             </script>")
      return self
  end

end

# instance = LocalServer.new
