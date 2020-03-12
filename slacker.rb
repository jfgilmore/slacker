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

# if prompt.yes?("Hi#{session.name != '' ? " #{session.name}! Do you want to sign in with a different account?" : "! Do you want to authorise slacker?"}")
if prompt.yes?("Do you want to login to Slack?")
  slack = Slack.new
puts "Login error" unless slack.login
else
  close
end

while true
  previous = ''
  case slack.channel
  when :ch || ''
    close unless slack.channel = prompt.select("Select a channel:", slack.conversations)
    previous = :ch
  when :pm
    close unless slack.channel = prompt.select("Select a private message thread:", slack.personal_messages)
    previous = :pm
  else
  end
  
  # Begin a chat session
  puts "Leave message blank to change conversation"
  chat = true
  while chat == true
    print "#{slack.channel_name}:"
    msg = gets.chomp
    chat = slack.message msg
  end
  slack.channel = previous
end

close
  # session.message = prompt(session.conversations)
