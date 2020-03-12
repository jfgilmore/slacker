#!/Users/joshuagilmore/.rbenv/shims/ruby
`clear`

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# On first run generate config files and run bundle install
    unless File.exist? File.expand_path('config', __dir__)
      p 'generating config files...'
      `mkdir #{File.expand_path('config', __dir__)}`
      `chmod -R 0400 config`
      `bundle install`    # Install any missing gems
    end

require 'artii'
require 'colorize'
require 'colorized_string'
require 'tty-prompt'
require_relative 'Slack'

prompt = TTY::Prompt.new

$art = Artii::Base.new
state = true

# Print closing tag
def close
  `clear`
  line
  puts "Thanks for using______\n#{$art.asciify("Slacker").colorize(:green)}"
  line
  exit
end

def get_text
  gets.chomp
end

def line
  puts '-' * 40
end

# Opening tag
`clear`
line
puts $art.asciify("Slacker").colorize(:green)
line

# Check internet connection available
def online
  require_relative 'LocalServer'
  check = LocalServer.new 
  check.get 'https://google.com'
end

online

# Prompt user to sign in.
if prompt.yes?("Do you want to login to Slack?")
  slack = Slack.new
puts "Login error, please try again" unless slack.login
else
  close
end

previous = ''
while true
  while slack.conversation == :pm || :ch || false
    case slack.conversation
    when :ch || ''
      close unless slack.conversation = prompt.select("Select a channel:", slack.channels)
      previous = :ch
    when :pm
      close unless slack.conversation = prompt.select("Select a private message thread:", slack.users)
      previous = :pm
    when false
      close
    else
      break
    end
  end

  # Get History, print
  # slack.history

  # Begin a chat session
  puts "Leave message blank to change conversation"
  chat = true
  while chat
    print "#{slack.conversation_name}:"
    msg = get_text
    chat = slack.message msg
    "Message undelivered: check your internet connection" unless chat == true
  end
  slack.conversation = previous
end

close
  # session.message = prompt(session.conversations)
