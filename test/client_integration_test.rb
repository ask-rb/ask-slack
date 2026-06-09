# frozen_string_literal: true

require_relative "test_helper"

class ClientIntegrationTest < Minitest::Test
  NO_DELAY = { base_delay: 0 }

  def setup
    Ask::Auth.reset_configuration!
  end

  def test_client_returns_slack_web_client_when_token_available
    token = "xoxb-test-token-12345"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "slack_token" }]
    end

    client = Ask::Slack.client(**NO_DELAY)
    assert_kind_of ::Slack::Web::Client, client
    refute_nil client.token
  end

  def test_client_raises_missing_credential_without_token
    Ask::Auth.configure do |config|
      config.providers = []
    end

    assert_raises(Ask::Auth::MissingCredential) { Ask::Slack.client(**NO_DELAY) }
  end

  def test_client_raises_invalid_credential_on_network_error
    token = "xoxb-test-token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "slack_token" }]
    end

    ::Slack::Web::Client.any_instance.stubs(:users_list).raises(
      ::Faraday::ConnectionFailed, "connection refused"
    )

    client = Ask::Slack.client(**NO_DELAY)
    error = assert_raises(::Ask::Auth::InvalidCredential) { client.users_list }
    assert_match(/connection refused/, error.message)
  end

  def test_client_handles_timeout_error
    token = "xoxb-test-token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "slack_token" }]
    end

    ::Slack::Web::Client.any_instance.stubs(:users_list).raises(
      ::Faraday::TimeoutError, "timed out"
    )

    client = Ask::Slack.client(**NO_DELAY)
    error = assert_raises(::Ask::Auth::InvalidCredential) { client.users_list }
    assert_match(/timed out/, error.message)
  end

  def test_client_retries_exhaust_all_attempts
    token = "xoxb-test-token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "slack_token" }]
    end

    # Raised every time — all 1 initial + 3 retries will fail
    ::Slack::Web::Client.any_instance.stubs(:users_list).raises(
      ::Faraday::ConnectionFailed, "persistent failure"
    )

    client = Ask::Slack.client(**NO_DELAY)
    error = assert_raises(::Ask::Auth::InvalidCredential) { client.users_list }
    assert_match(/persistent failure/, error.message)
  end

  def test_client_timeouts_configured
    token = "xoxb-test-token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "slack_token" }]
    end

    client = Ask::Slack.client(**NO_DELAY)
    assert_equal 30, client.timeout
    assert_equal 10, client.open_timeout
  end

  def test_client_retryable_error_types_defined
    retryable = Ask::Slack::ClientProxy::RETRYABLE_ERRORS
    assert_includes retryable, ::Faraday::TimeoutError
    assert_includes retryable, ::Faraday::ConnectionFailed
    assert_includes retryable, ::Faraday::ServerError
    assert_includes retryable, ::Errno::ECONNREFUSED
    assert_includes retryable, ::Errno::ECONNRESET
    assert_includes retryable, ::Timeout::Error
  end

  def test_client_sets_max_retries_constant
    assert_equal 3, Ask::Slack::ClientProxy::MAX_RETRIES
  end
end
