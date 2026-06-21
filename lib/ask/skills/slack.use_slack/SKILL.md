---
name: slack.use_slack
description: How to navigate the Slack API with slack-ruby-client — discover methods, handle auth, pagination, and errors
---

Use this skill when you need to interact with Slack — posting messages, reading
channels, managing users, uploading files, or searching conversations.

## Step 1: Get the Client

```ruby
client = Ask::Slack.client
```

This returns an authenticated `Slack::Web::Client`. It expects a valid Slack Bot
User OAuth Token resolved via `Ask::Auth.resolve(:slack_token)`.

If you get an auth error, read `Ask::Slack::Context::AUTH_HOW` for token setup.

## Step 2: Explore the Context

The gem ships with structured context you should reference:

```ruby
Ask::Slack::Context::DOCS_URL    # Slack Web API methods docs
Ask::Slack::Context::GEM_DOCS    # slack-ruby-client Ruby docs
Ask::Slack::Context::QUICK_START # Copy-paste examples
Ask::Slack::Context::GEM_NAME    # "slack-ruby-client"
```

The `QUICK_START` constant has basic examples for channels, messaging, and users.

## Step 3: Discover Available Methods

Use code tools to explore the underlying SDK client:

```ruby
Code.new.call(code: "
  client = Ask::Slack.client.client  # unwrap proxy to get raw client
  puts client.methods(false).sort.join(\"\\n\")
")
```

Common Slack API methods:
- `client.chat_postMessage(channel:, text:, blocks:)` — send a message
- `client.conversations_list` — list public channels
- `client.conversations_history(channel:)` — read channel history
- `client.conversations_replies(channel:, ts:)` — get thread replies
- `client.users_list` — list workspace users
- `client.files_upload_v2(channels:, content:, file:)` — upload files

For method details, read the slack-ruby-client source:
```ruby
# Discover the underlying WebClient methods
Read.new.call(path: "$GEM_PATH/slack-ruby-client-*/lib/slack/web/client.rb")
```

## Step 4: Authentication & Common Errors

Auth failures are converted to `Ask::Auth::InvalidCredential`. For detailed
error guidance, use:

```ruby
Ask::Slack::Errors.for("channel_not_found")
Ask::Slack::Errors.status_code_description(429)
Ask::Slack::Errors::RATE_LIMIT
Ask::Slack::Errors::PAGINATION
```

Common scenarios:
- **not_in_channel**: Bot isn't in that channel → invite or use `conversations_join`
- **missing_scope**: Token lacks required OAuth scope → add at api.slack.com/apps
- **rate_limited**: Exceeded per-method limit → check Retry-After header
- **invalid_blocks**: Block Kit JSON has validation errors

## Step 5: Pagination

Slack uses cursor-based pagination. The pattern is:

```ruby
response = client.conversations_list(limit: 200)
cursor = response.response_metadata.next_cursor
# Pass cursor in next request:
client.conversations_list(limit: 200, cursor: cursor) unless cursor.empty?
```

Most list methods accept `limit` (max 200) and `cursor` parameters.

## Step 6: Message Formatting

For rich messages, use Block Kit (JSON blocks). The `QUICK_START` constant
has examples for header, section, context, divider, and actions blocks. For
detailed Block Kit reference, see the Slack API docs.

## Step 7: Fallback Strategy

If the SDK doesn't have a method for what you need:
1. Check `Ask::Slack::Context::DOCS_URL` for the API method
2. Use `client.post("method.name", params)` for custom API calls
3. Use `client.get("conversations.list")` style for raw endpoint access
