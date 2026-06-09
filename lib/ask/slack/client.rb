# frozen_string_literal: true

require "slack-ruby-client"
require "ask/auth"

module Ask
  module Slack
    # Returns an authenticated Slack Web API client configured for an AI agent.
    #
    # Resolves the Slack token via +Ask::Auth.resolve(:slack_token)+ and
    # wraps the client in a proxy that converts +::Slack::Web::Api::Errors::SlackError+
    # authentication errors into +Ask::Auth::InvalidCredential+.
    #
    # Configuration:
    # - Uses the resolved token for authentication
    # - Default user agent is set by slack-ruby-client
    #
    # @example
    #   client = Ask::Slack.client
    #   client.channels_list
    #   client.chat_postMessage(channel: "#general", text: "Hello!")
    #
    # @return [::Slack::Web::Client] an authenticated client
    # @raise [Ask::Auth::MissingCredential] if no Slack token is configured
    # @raise [Ask::Auth::InvalidCredential] if the token is rejected
    def self.client
      token = Ask::Auth.resolve(:slack_token)

      ClientProxy.new(::Slack::Web::Client.new(token: token))
    end

    # Proxies method calls to a +::Slack::Web::Client+, converting authentication
    # errors into +Ask::Auth::InvalidCredential+.
    class ClientProxy < ::BasicObject
      def initialize(client)
        @client = client
      end

      def method_missing(name, ...)
        @client.public_send(name, ...)
      rescue ::Slack::Web::Api::Errors::NotAuthed,
             ::Slack::Web::Api::Errors::InvalidAuth,
             ::Slack::Web::Api::Errors::AccountInactive,
             ::Slack::Web::Api::Errors::TokenRevoked,
             ::Slack::Web::Api::Errors::TokenExpired
        ::Kernel.raise ::Ask::Auth::InvalidCredential, :slack_token
      end

      def respond_to_missing?(name, include_private = false)
        @client.respond_to?(name, include_private) || super
      end
    end
  end
end
