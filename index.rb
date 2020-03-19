#!/Users/gilmore/.rbenv/shims/ruby
# frozen_string_literal=true
# require 'pry'
require 'ruby-debug-ide'
require 'bundler/setup'
Bundler.require(:default, :development)
require 'rubygems'
require 'artii'
require 'colorize'
require 'colorized_string'
require 'tty-prompt'
require 'redcarpet'
require 'redcarpet/render_strip'
require_relative 'lib/slack'
require_relative 'lib/local_server'

system('clear')
# On first run generate config files and run bundle install
unless File.exist? File.expand_path('config', __dir__)
  puts 'generating config files...'
  `mkdir #{File.expand_path('config', __dir__)}`
  `chmod -R 0400 config`
  `bundle install` # Install any missing gems
end

quick = false
quick = true if ARGV.include? '-q'
if ARGV.include? '-uninstall'
  # remove application and encryption keys & secret codes
end
if ARGV.include? '-recover'
  # reinstall from web to recover any missing files/credentials
end
if ARGV.include?('-v') || ARGV.include?('man')
  # show version
  file = File.read File.expand_path('README.md', __dir__)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  if ARGV.include? '-v'
    file.each_line do |l|
      if l.match(/version:....../)
        puts l.match(/version:....../)
        break
      end
    end
  end
end
if ARGV.include? 'man'
  puts markdown.render file
  exit
end

# Print closing tag
def close
  system('clear')
  line
  puts "Thanks for using______\n#{$art.asciify('Slacker').colorize(:green)}"
  line
  exit
end

def line
  puts '-' * 40
end

prompt = TTY::Prompt.new
$art = Artii::Base.new

# Opening tag
line
puts $art.asciify('Slacker').colorize(:green)
line

# Check internet connection available
def online
  check = LocalServer.new
  check.get 'https://google.com'
end

# start a REPL session
# binding.pry

online
# If the quick login argument given, skip the login y/n prompt
if quick
  slack = Slack.new
else
  # Prompt user to sign in.
  prompt.yes?('Do you want to login to Slack?') ? slack = Slack.new : close
  # need timout error handling :(
end
puts 'Login error, please try again' unless slack.login

previous = :ch
type = slack.channels
loop do
  while slack.conversation == :pm || slack.conversation == :ch ||
        !slack.conversation
    system('clear')
    previous = slack.conversation
    slack.conversation = prompt.select 'Select a conversation thread:', type, filter: true
    case slack.conversation
    when :ch
      type = slack.channels
    when :pm
      type = slack.users
    when false
      close
    end
  end

  # Get History, print
  # slack.history

  # Begin a chat session
  puts 'Leave message blank to change conversation'
  chat = true
  while chat
    print "#{slack.conversation_name}:"
    msg = gets.chomp
    chat = slack.message msg
    'Message undelivered: check your internet connection' unless chat == true
  end
  slack.conversation = previous
end
