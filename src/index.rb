#!/Users/joshuagilmore/.rbenv/shims/ruby
`clear`
quick = false

for entry in 0 ... ARGV.length
  require 'redcarpet'
  require 'redcarpet/render_strip'
  arg = ARGV[entry]
  if arg == '-q'
    quick = true
  end
  if arg == '-uninstall'
    # remove application and encryption keys & secret codes 
  end
  if arg == '-v' || arg == 'man'
    #show version
    file = File.read File.expand_path('README.md', __dir__)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    if arg == '-v'
      file.each_line do |l|
        if l.match(/version:....../)
          puts l.match(/version:....../)
          break
        end
      end
    end
  end
  if arg == 'man'
    puts markdown.render file
    exit
  end
end
`clear`

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# On first run generate config files and run bundle install
unless File.exist? File.expand_path('config', __dir__)
  p 'generating config files...'
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
state = true

# Print closing tag
def close
  `clear`
  line
  puts "Thanks for using______\n#{$art.asciify('Slacker').colorize(:green)}"
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
puts $art.asciify('Slacker').colorize(:green)
line

# Check internet connection available
def online
  require_relative 'lib/LocalServer'
  check = LocalServer.new
  check.get 'https://google.com'
end

online
`clear`
# If the quick login argument given, skip the login y/n prompt
unless quick
# Prompt user to sign in.
  if prompt.yes?('Do you want to login to Slack?')
    slack = Slack.new
  else
    close
  end
else
  slack = Slack.new
end
puts 'Login error, please try again' unless slack.login

previous = ''
loop do
  while slack.conversation == :pm || slack.conversation == :ch || slack.conversation == false
    case slack.conversation
    when :ch || ''
      unless slack.conversation = prompt.select('Select a channel:', slack.channels)
        close
      end
      previous = :ch
    when :pm
      unless slack.conversation = prompt.select('Select a private message thread:', slack.users)
        close
      end
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
  puts 'Leave message blank to change conversation'
  chat = true
  while chat
    print "#{slack.conversation_name}:"
    msg = get_text
    chat = slack.message msg
    'Message undelivered: check your internet connection' unless chat == true
  end
  slack.conversation = previous
end

close
# session.message = prompt(session.conversations)
