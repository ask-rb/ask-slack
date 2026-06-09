# ask-slack

Slack service context for the ask-rb ecosystem.

Provides:
- `Ask::Slack.client` — authenticated Slack Web API client
- `Ask::Slack::DESCRIPTION` — context metadata for the system prompt
- `Ask::Slack::Errors` — structured error knowledge for agents

## Installation

```ruby
gem "ask-slack"
```

## Usage

```ruby
require "ask-slack"

client = Ask::Slack.client
client.chat_postMessage(channel: "#general", text: "Hello from ask-rb!")
client.conversations_list
client.users_list
```

## Authentication

Set your Slack Bot User OAuth Token:

```bash
export SLACK_TOKEN=xoxb-your-bot-token-here
```

Or add it to `~/.ask/credentials.yml`:

```yaml
slack_token: xoxb-your-bot-token-here
```

## Development

```bash
bundle install
bundle exec rake test
```

## License

MIT
