# frozen_string_literal: true

require "slack-ruby-client"
require "ask/auth"

module Ask
  module Slack
    # Returns an authenticated Slack Web API client configured for an AI agent.
    #
    # Resolves the Slack token via +Ask::Auth.resolve(:slack_token)+ and
    # configures the client with sensible defaults:
    #
    # - +timeout+: 30 seconds for HTTP requests
    # - +open_timeout+: 10 seconds for TCP connection
    #
    # Retry behaviour: +ClientProxy+ retries transient Faraday and network
    # errors up to 3 times with exponential backoff before raising
    # +Ask::Auth::InvalidCredential+.
    #
    # The client is wrapped in a +ClientProxy+ that:
    # 1. Converts auth errors (+NotAuthed+, +InvalidAuth+, etc.) into
    #    +Ask::Auth::InvalidCredential+
    # 2. Retries transient network failures with exponential backoff
    #
    # @example
    #   client = Ask::Slack.client
    #   client.channels_list
    #   client.chat_postMessage(channel: "#general", text: "Hello!")
    #
    # @return [::Slack::Web::Client] an authenticated client
    # @raise [Ask::Auth::MissingCredential] if no Slack token is configured
    # @raise [Ask::Auth::InvalidCredential] if the token is rejected
    def self.client(base_delay: nil)
      token = Ask::Auth.resolve(:slack_token)

      ClientProxy.new(::Slack::Web::Client.new(
        token: token,
        timeout: 30,
        open_timeout: 10
      ), base_delay: base_delay)
    end

    # Proxies method calls to a +::Slack::Web::Client+, converting auth errors
    # and retrying transient network failures with exponential backoff.
    class ClientProxy < ::BasicObject
      MAX_RETRIES = 3
      RETRYABLE_ERRORS = [
        ::Faraday::TimeoutError,
        ::Faraday::ConnectionFailed,
        ::Faraday::ServerError,
        ::Errno::ECONNREFUSED,
        ::Errno::ECONNRESET,
        ::Timeout::Error
      ].freeze

      attr_reader :client

      def initialize(client, base_delay: nil)
        @client = client
        @_base_delay = base_delay || 1
      end

      def method_missing(name, ...)
        retry_count = 0
        begin
          @client.public_send(name, ...)
        rescue ::Slack::Web::Api::Errors::NotAuthed,
               ::Slack::Web::Api::Errors::InvalidAuth,
               ::Slack::Web::Api::Errors::AccountInactive,
               ::Slack::Web::Api::Errors::TokenRevoked,
               ::Slack::Web::Api::Errors::TokenExpired
          ::Kernel.raise ::Ask::Auth::InvalidCredential, :slack_token
        rescue *RETRYABLE_ERRORS => e
          retry_count += 1
          if retry_count <= MAX_RETRIES
            ::Kernel.sleep(@_base_delay * (2 ** (retry_count - 1)))
            retry
          end
          ::Kernel.raise ::Ask::Auth::InvalidCredential.new(:slack_token, e.message)
        end
      end

      def respond_to_missing?(name, include_private = false)
        @client.respond_to?(name, include_private) || super
      end
    end
  end
end
