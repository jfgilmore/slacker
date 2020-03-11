#!/Users/joshuagilmore/.rbenv/shims/ruby

`clear`

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
`bundle install`    # Install any missing gems
require 'artii'
require 'colorize'
require 'colorized_string'
require 'pony'
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

session = Slack.new
# if prompt.yes?("Hi#{session.name != '' ? " #{session.name}! Do you want to sign in with a different account?" : "! Do you want to authorise slacker?"}")
if prompt.yes?("Hi! Do you want to re-authorise slacker?")
  session = Slack.new false
  session.login
else
  close
end

  session.active_chat = prompt(session.conversations) unless session.active_chat

  session.message = prompt(session.conversations)
