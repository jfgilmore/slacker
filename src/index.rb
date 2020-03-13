#!/Users/joshuagilmore/.rbenv/shims/ruby

quick = false
require 'redcarpet'
require 'redcarpet/render_strip'
quick = true if ARGV.include? '-q'
if ARGV.include? '-uninstall'
  # remove application and encryption keys & secret codes
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

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# On first run generate config files and run bundle install
unless File.exist? File.expand_path('config', __dir__)
  puts 'generating config files...'
  `mkdir #{File.expand_path('config', __dir__)}`
  `chmod -R 0400 config`
  `bundle install` # Install any missing gems
end

require 'artii'
require 'colorize'
require 'colorized_string'
require 'tty-prompt'
require_relative 'lib/Slack'

prompt = TTY::Prompt.new
$art = Artii::Base.new

# Print closing tag
def close
  line
  puts "Thanks for using______\n#{$art.asciify('Slacker').colorize(:green)}"
  line
  exit
end

def line
  puts '-' * 40
end

# Opening tag
line
puts $art.asciify('Slacker').colorize(:green)
line

# Check internet connection available
def online
  require_relative 'lib/LocalServer'
  check = LocalServer.new
  check.get 'https://google.com'
end

online
# If the quick login argument given, skip the login y/n prompt
if quick
  slack = Slack.new
else
  # Prompt user to sign in.
  prompt.yes?('Do you want to login to Slack?') ? slack = Slack.new : close
end
puts 'Login error, please try again' unless slack.login

previous = :ch
type = slack.channels
loop do
  while slack.conversation == :pm || slack.conversation == :ch || !slack.conversation
    previous = slack.conversation
    slack.conversation = prompt.select 'Select a private message thread:', type
    case slack.conversation
    when :ch
      type = slack.channels
    when :pm
      type = slack.users
    when false
      close
    else
      # break
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
