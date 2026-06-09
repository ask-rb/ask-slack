# frozen_string_literal: true

module Ask
  module Slack
    # Structured error knowledge for AI agents working with the Slack Web API.
    #
    # Provides human-readable guidance for common HTTP status codes, rate
    # limiting, pagination, and authentication errors encountered when
    # using the slack-ruby-client.
    module Errors
      # Rate limit information.
      #
      # Slack rate limits are applied per-method, per-app. Limits vary
      # by endpoint. When rate-limited, +Slack::Web::Api::Errors::TooManyRequestsError+
      # is raised with a +Retry-After+ header.
      RATE_LIMIT = {
        typical_limit: "Varies per method (typically 1–50 requests per minute per app)",
        error_class: "Slack::Web::Api::Errors::TooManyRequestsError",
        retry_header: "Retry-After (seconds)",
        action: "Wait for the Retry-After duration, then retry the request. Use the retry_after method on the error."
      }.freeze

      # Common error strings returned by the Slack Web API and how to handle them.
      ERRORS = {
        "not_authed" => {
          message: "No authentication token provided.",
          action: "Ensure Ask::Slack.client is called with a valid token. Check that SLACK_TOKEN is set."
        },
        "invalid_auth" => {
          message: "The authentication token is invalid or malformed.",
          action: "Verify your Slack token is correct. It should start with xoxb- (bot) or xoxp- (user)."
        },
        "account_inactive" => {
          message: "The authentication token is for a deleted or disabled account.",
          action: "Reactivate the Slack app or generate a new token at https://api.slack.com/apps."
        },
        "token_revoked" => {
          message: "The authentication token has been revoked.",
          action: "Generate a new token at https://api.slack.com/apps and update your credentials."
        },
        "token_expired" => {
          message: "The authentication token has expired.",
          action: "Refresh the token or generate a new one at https://api.slack.com/apps."
        },
        "token_not_found" => {
          message: "The authentication token could not be found.",
          action: "Check that the token has been properly set via Ask::Auth."
        },
        "rate_limited" => {
          message: "Slack API rate limit exceeded.",
          action: "Check the Retry-After header, wait the specified duration, then retry. Use Slack::Web::Api::Errors::TooManyRequestsError#retry_after."
        },
        "ratelimited" => {
          message: "Slack API rate limit exceeded (alternative error string).",
          action: "Same as 'rate_limited' — wait for the Retry-After duration, then retry."
        },
        "channel_not_found" => {
          message: "The specified channel was not found.",
          action: "Verify the channel ID (starts with C) or channel name. Fetch available channels with client.conversations_list."
        },
        "user_not_found" => {
          message: "The specified user was not found.",
          action: "Verify the user ID (starts with U) or email. Fetch available users with client.users_list."
        },
        "not_in_channel" => {
          message: "The bot user is not a member of the specified channel.",
          action: "Invite the bot to the channel or use client.conversations_join to join public channels."
        },
        "restricted_action" => {
          message: "The token lacks the required scopes for this action.",
          action: "Add the required OAuth scope to your Slack app at https://api.slack.com/apps and reinstall."
        },
        "missing_scope" => {
          message: "The token is missing a required OAuth scope.",
          action: "Add the required scope at https://api.slack.com/apps, then reinstall the app to your workspace."
        },
        "invalid_arguments" => {
          message: "The request contained invalid arguments.",
          action: "Check the required parameters and data types for the method. See https://api.slack.com/methods for details."
        },
        "internal_error" => {
          message: "Slack encountered an internal server error.",
          action: "Retry with exponential backoff. If the issue persists, check https://status.slack.com."
        },
        "service_unavailable" => {
          message: "Slack service is temporarily unavailable.",
          action: "Retry with backoff. Check https://status.slack.com for ongoing incidents."
        },
        "fatal_error" => {
          message: "Slack encountered a fatal error.",
          action: "Retry with exponential backoff. Contact Slack support if the issue persists."
        },
        "deprecated_endpoint" => {
          message: "The API endpoint has been deprecated.",
          action: "Check https://api.slack.com/changelog for the replacement endpoint."
        }
      }.freeze

      # HTTP status codes commonly returned by the Slack API.
      STATUS_CODES = {
        200 => "OK — Request succeeded.",
        201 => "Created — File or resource was created.",
        204 => "No Content — Request succeeded, no response body.",
        400 => "Bad Request — Invalid parameters. Check the error field in the response.",
        401 => "Unauthorized — Token missing or invalid. Re-authenticate.",
        403 => "Forbidden — Token lacks required scopes.",
        404 => "Not Found — Resource does not exist.",
        429 => "Too Many Requests — Rate limit exceeded. Use Retry-After header.",
        500 => "Internal Server Error — Slack server issue. Retry with backoff.",
        502 => "Bad Gateway — Slack upstream issue. Retry with backoff.",
        503 => "Service Unavailable — Slack is down for maintenance. Retry later."
      }.freeze

      # Pagination guidance for large result sets.
      PAGINATION = {
        cursor_based: "Slack uses cursor-based pagination via the 'next_cursor' field in response_metadata.",
        limit: "Use the 'limit' parameter to set page size (max 200 for most endpoints).",
        pattern: "Set cursor parameter to response_metadata.next_cursor from the previous response.",
        max_results: "For large result sets, iterate through all cursors."
      }.freeze

      # Map of Slack error strings to common exception classes.
      EXCEPTION_CLASSES = {
        "not_authed" => "Slack::Web::Api::Errors::NotAuthed",
        "invalid_auth" => "Slack::Web::Api::Errors::InvalidAuth",
        "account_inactive" => "Slack::Web::Api::Errors::AccountInactive",
        "token_revoked" => "Slack::Web::Api::Errors::TokenRevoked",
        "token_expired" => "Slack::Web::Api::Errors::TokenExpired",
        "rate_limited" => "Slack::Web::Api::Errors::TooManyRequestsError",
        "channel_not_found" => "Slack::Web::Api::Errors::ChannelNotFound",
        "user_not_found" => "Slack::Web::Api::Errors::UserNotFound"
      }.freeze

      # Look up guidance for a Slack error string.
      #
      # @param error_string [String] The Slack API error string (e.g., "channel_not_found")
      # @return [Hash, nil] A hash with +:message+ and +:action+ keys, or nil if unknown
      def self.for(error_string)
        ERRORS[error_string]
      end

      # Describe an HTTP status code.
      #
      # @param code [Integer] HTTP status code
      # @return [String, nil] Description of the status code
      def self.status_code_description(code)
        STATUS_CODES[code]
      end

      # Look up the exception class name for a Slack error string.
      #
      # @param error_string [String] The Slack API error string
      # @return [String, nil] The fully qualified exception class name
      def self.exception_class(error_string)
        EXCEPTION_CLASSES[error_string]
      end
    end
  end
end
