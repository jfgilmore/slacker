# slacker
Ever wanted to be slacker than **Slack**? Well now you can. *Slacker* allows you to post to your slack channels or contacts without leaving the terminal.

Many of us use slack for personal or organisational communication, but as developers we sometimes loathe to go outside the comfort of our terminal. I remember hearing that you can do pretty much everything from the terminal. However it's not always efficient or simple. So rather than using *curl* to send something to slack I conceived a simpler method without a lot of verbose arguments. This app is clearly meant for the developers among us however will feel natural to use even for those unfamiliar with the command line interface.

For now we have settled for getting a user authenticated with Slack via the OAuth2 protocol, retrieving a list of active channels and contacts from your active workspace. Ultimately **slacker** will enable you to retrieve the last few messages in a chat for context, provide up to date posts on all of your open chats, and allow multi person direct message chat functionality.

Future revisions should add better security, use threads to allow for messages to be pushed into the application from Slack, and store the users credentials so you don't need to re-authenticate yourself in every session.

## version: 0.0.2

### github repo
```
https://github.com/djsounddog/slacker
```

## Installation

``` THIS IS NOT YET AVAILABLE AS A GEM, PLEASE DISREGARD THESE INSTRUCTIONS UNTIL FURTHER NOTICE ```

Add this line to your application's Gemfile:

```ruby
gem 'slacker'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install slacker



## Usage

1. Execute from the terminal the command: slacker
2. Choose if you want to proceed with login (y/n then [ENTER])
3. Select the #channel you want to post to or change mode to personal messages using the [UP] and [DOWN] arrows.
4. Type your message into the terminal and hit enter to send. Your message will be posted to the selected #channel or direct message chat.
5. Hit enter with no text input and you will return to the context menu
6. Change modes or choose <Exit> to end your *slacker* session

If something goes wrong you'll generally be given an error code displayed on the screen to let you know what went wrong.

### Terminal arguments
-q is quick login mode, skips the login prompt and goes straight to authentication

-v will display the version number on load

-uninstall (not yet implemented) will remove all traces of *slacker* from your computer.

man will display this README.md

Arguments can be combined but 'man' will terminate the application before authentication.

## Features

### Authenticator
Worthy of being a gem itself. This class is the security layer of slacker. When an instance is initialized it creates a collection of instance variables utilised in the OAuth2 protocol. It loads slacker's client token and secret key that was provided by Slack. Authenticator uses the Launchy gem to 
open a get request in users default browser to retrieve a user *code*. At this point it also initializes an instance of the LocalServer class (this could be a module to be honest). The LocalServer spins up a server on localhost port 3000 to receive the code returned by the OAuth API.

Once the Authenticator has this code it then requests a user session token from Slack.com. It currently holds the token and code in RAM as I full encryption is unfortunately something I will not be able to deliver by the project deadline.

This Authenticator class now acts as a request server which passes API requests from the Slack class through to the LocalServer class adding the users token as it passes through. This way in theory the users token isn't exposed.

I intend for each class in this application to be able to become a gem in itself. I had this idea after encountering difficulties using the existing OAuth2 ruby gem, in coding Authenticator I have built my own.

### Slack

The Slack class is the API interface between slacker and Slack.com. It compiles requests in the format:

```application/x-www-form-urlencoded```

Then sending them through the Authenticator and LocalServer to the Slack API.

When it is initialized it opens triggers the Authenticator to sign onto slack by retrieving the users token. Theoretically any Slack style app could utilise the Authenticator in this way. The Slack class sends the API url, the requested permission scope, the applications client id, and the client secret to the Authenticator. The Authenticator class is stored in the @user instance variable for further use.

The Slack class then handles method calls from slacker to login the user, post messages to the selected channel (stored as an instance variable), or return user and channel lists. In future it will also be able to log the user out of a session, deleting the users token from the config folder.

### LocalServer

The dumb waiter of the slacker application. It uses the HTTParty and Launchy gems to send and receive payloads from the internet. It has some level of error checking in that it checks for successful (200) response codes. However otherwise is a silo that allows me to maintain cleaner code in the other classes and the main code.

### slacker(main body)

Slacker itself loads the app from the command line without requiring the ruby command, it checks if the application has been run before by looking for its config folder. If it's not present it will create the folder and run the bundle install gem command to install all the gems required by slacker and its classes.

Arguments passed are checked.
- A quick login option that bypasses the login yes/no option, this will be more handy later when the user token/code is stashed for future use. 
- An uninstall command for when you are sick of slacker of having issues, I may also add a reinstall option in a later revision to fix any issues acquired over time.
- A version getter that reads the README.md file for the current version number.
- A manual option that will display the full README.md text in the terminal rather than starting slacker.

It will load all its required gems for making things look pretty mostly I will be using Artii, colorize, and tty-prompt.

Slacker then defines some methods:
- Close method which cleans up the terminal and stashes keys and codes before exiting. This could be changed to a Proc in future. Not sure, it depends on what I need it to do.

- User command getter, it is really just gets.chomp to knock off pesky return characters. This method could be changed in future to accept rich text messages from the terminal. But for now it's text only messages.

- Line method, it just puts multiple '-' to the terminal to pretty things up a bit and define changes in mode for the user.

It checks for internet connection by pinging google.com, tells you to check your internet connection before continuing if it fails.

The main body of code is then run. The user login prompt, if not skipped by the 'quick' argument, will run entering 'yes' or 'y' will begin a new Slack session. If the user types 'n' or 'no' slacker will execute its close method. Slacker will then send a login request to the Authenticator to start a session. If this fails it will provide feedback to try again.

A loop is started that will continue unless the close method is called.

Another loop begins. The user is prompted to select a slack #channel, <Exit> or change to Private Messages. This prompt is built by tty-prompt, the Slack class conversations method puts this list in the appropriate format to be interpreted by tty-prompt when the user logs in. Tty returns the conversation id to be added to an API request, or returns false initiating the close command on the next loop for <Exit>, or a token :pm or :ch indicating a change of mode. If the previous selection is different from the new selection the current loop repeats to bring up the new context menu or execute the close command. This loop is then broken if the slack.conversation variable is a conversation id.

A loop begins to facilitate chat messages. A boolean variable is initialized as true. We now enter a while loop that checks this boolean, when true it proceeds to print the conversation name to the terminal as a message prompt. It also prints that if you hit [ENTER] when the prompt is blank you will be returned to the menu. The code loop back and prints another conversation name as a prompt or breaks the loop and returns to the beginning of the outer loop to go back to the context menu prompt, storing the current conversation id as the previous variable on the way.

Tty-prompt helps avoid any syntax errors from the user typing the wrong thing at the conversation context menu. You can however type whatever you want at the message prompt, so long as it is ASCII encoded, it will send it as a message.

Future plans to add a chat history method within the main loop.


## Sources

- A list of gems included is contained in my [Gemfile](https://github.com/djsounddog/slacker/blob/master/Gemfile)

- All gems i have used are open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

- This application uses [**OAuth2**](https://oauth.net/2/) to authenticate itself and the user session with [**Slack**](https://slack.com).

- I utilised documentation from the [Slack API](https://api.slack.com/) page, [ruby-doc.org](https://ruby-doc.org/), and much help on methods and syntax from the [Stack Overflow](https://stackoverflow.com/) forums.

- Big shout out to the teachers and staff at [coderacademy](https://coderacademy.edu.au/) for all their help, support, and motivation.

## Development

*Slacker* will be released as a ruby gem in future however at this point in time the application is not secure at the application or user level. There is currently a branch in the repo where full token and code encryption is being developed.

### Trello

The project management side of thing goes on [here](https://trello.com/b/43fPLAbw/t1a2-terminal-project)

## Contributing

Contributions to this application will be welcome after the initial phase (of my bootcamp project) is completed. Until then any pull requests will be rejected or ignored.

Bug reports and pull requests are welcome on GitHub at https://github.com/djsounddog/slacker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/listi/blob/master/CODE_OF_CONDUCT.md).

## License

The application is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

<!-- image example -->
![Alt text](https://scontent.fsyd3-1.fna.fbcdn.net/v/t1.0-9/89347579_873189996441815_3626135038543790080_n.png?_nc_cat=111&_nc_sid=e007fa&_nc_ohc=pds-uNe2tp4AX_mwc3Z&_nc_ht=scontent.fsyd3-1.fna&oh=00c1c7b4af95fa7fa9b0fd72f1a14eae&oe=5E923363)

<!-- ## Code of Conduct

Everyone interacting in the slacker project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/djsounddog/slacker/blob/master/CODE_OF_CONDUCT.md). -->