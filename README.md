# ask-slack

slack service context for the ask-rb ecosystem.

Provides:
- `Ask::slack.client` — authenticated API client
- `Ask::slack.context` — context metadata for the system prompt
- `Ask::slack::Errors` — structured error knowledge for agents

## Installation

```ruby
gem "ask-slack"
```

## Usage

```ruby
client = Ask::slack.client
# ... use the client according to its API
```

## Development

```bash
bin/setup
bundle exec rake test
```

## License

MIT
