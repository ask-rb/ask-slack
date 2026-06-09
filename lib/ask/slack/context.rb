# frozen_string_literal: true

module Ask
  module Slack
    # Human-readable description of the Slack service context.
    DESCRIPTION = "Slack — messaging, channels, files, search, workspace management"

    # Base URL for Slack Web API methods.
    DOCS_URL = "https://api.slack.com/methods"

    # URL for the Slack OpenAPI specification.
    OPENAPI_URL = "https://api.slack.com/specs/openapi"

    # Credential name used with Ask::Auth.resolve.
    AUTH_NAME = :slack_token

    # Instructions for obtaining a Slack Bot User OAuth Token.
    AUTH_HOW = "Create a Slack app at https://api.slack.com/apps — get a Bot User OAuth Token (xoxb-). Scopes: chat:write, channels:read, users:read, files:read"

    # Gem name for the Slack API client.
    GEM_NAME = "slack-ruby-client"

    # Required gem version constraint.
    GEM_VERSION = "~> 3.1"

    # URL for slack-ruby-client library documentation.
    GEM_DOCS = "https://rubydoc.info/gems/slack-ruby-client"

    # Quick-start Ruby code snippet for agents to copy-paste.
    QUICK_START = <<~RUBY
      client = Ask::Slack.client
      client.channels_list
      client.conversations_list
      client.chat_postMessage(channel: "#general", text: "Hello from ask-rb!")
      client.users_list
      client.conversations_history(channel: "C123456")
    RUBY
  end
end
