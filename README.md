# ask-slack

[![Gem Version](https://badge.fury.io/rb/ask-slack.svg)](https://badge.fury.io/rb/ask-slack)

> **DEPRECATED:** The `ask-slack` gem is deprecated in favor of Slack's
> [official MCP server](https://docs.slack.dev/ai/slack-mcp-server/)
> (endpoint: `https://mcp.slack.com/mcp`). Existing installations may continue
> to work, but this repository will receive no further feature development.
> For setup and capabilities, use the
> [official MCP source](https://docs.slack.dev/ai/slack-mcp-server/).

Slack service context for AI agents in the ask-rb ecosystem. It provides an
authenticated Slack Web API client built on slack-ruby-client, metadata
constants for system prompts, and a structured error guide for common Slack
API issues.

## Installation

```ruby
gem "ask-slack"
```

## Quick Start

```ruby
require "ask-slack"

client = Ask::Slack.client
client.chat_postMessage(channel: "#general", text: "Hello from ask-rb!")
client.conversations_list
client.users_list
```

## Authentication

`Ask::Slack.client` resolves a token via `Ask::Auth.resolve(:slack_token)`.
Set your Slack Bot User OAuth Token in the environment:

```bash
export SLACK_TOKEN=xoxb-your-bot-token-here
```

Or add it to `~/.ask/credentials.yml`:

```yaml
slack_token: xoxb-your-bot-token-here
```

Credentials can also come from Rails credentials, a database, or an OAuth
provider, depending on your `ask-auth` configuration. Create a Slack app at
[api.slack.com/apps](https://api.slack.com/apps) to get a bot token.

## Key entry points

- `Ask::Slack.client` - an authenticated `Slack::Web::Client`. It is wrapped
  in a proxy that converts auth errors (`NotAuthed`, `InvalidAuth`, and
  related) into `Ask::Auth::InvalidCredential` and retries transient network
  failures with exponential backoff.
- `Ask::Slack::Errors` - structured error knowledge for agents: guidance by
  error string, HTTP status code descriptions, and exception class mapping.
- `Ask::Slack::DESCRIPTION`, `DOCS_URL`, `AUTH_NAME`, `GEM_NAME`,
  `GEM_VERSION`, and `QUICK_START` - metadata constants for system prompts.

Use `conversations_list`, not `channels_list`. `channels_list` was removed in
modern versions of slack-ruby-client.

## Full documentation

The full ask-rb documentation lives at https://ask-rb.github.io/ask-docs.
[Services: Slack](https://ask-rb.github.io/ask-docs/services/slack) covers
ask-slack in depth, including the client, error guide, and constants.
API reference: https://ask-rb.github.io/ask-docs/reference/api.

## Development

```
bundle install
bundle exec rake test
```

## License

MIT
