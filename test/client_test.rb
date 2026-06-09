# frozen_string_literal: true

require_relative "test_helper"

class ClientTest < Minitest::Test
  def setup
    Ask::Auth.reset_configuration!
  end

  def test_client_returns_slack_web_client_when_token_available
    token = "xoxb-test-token-12345"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "slack_token" }]
    end

    client = Ask::Slack.client
    assert_kind_of Slack::Web::Client, client
    assert_equal token, client.token
  end

  def test_client_raises_missing_credential_without_token
    Ask::Auth.configure do |config|
      config.providers = []
    end

    assert_raises(Ask::Auth::MissingCredential) { Ask::Slack.client }
  end

  def test_client_raises_invalid_credential_on_invalid_auth
    token = "bad_token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "slack_token" }]
    end

    Slack::Web::Client.any_instance.stubs(:channels_list).raises(
      Slack::Web::Api::Errors::InvalidAuth.new("invalid_auth")
    )

    assert_raises(Ask::Auth::InvalidCredential) { Ask::Slack.client.channels_list }
  end

  def test_client_raises_invalid_credential_on_not_authed
    token = "bad_token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "slack_token" }]
    end

    Slack::Web::Client.any_instance.stubs(:channels_list).raises(
      Slack::Web::Api::Errors::NotAuthed.new("not_authed")
    )

    assert_raises(Ask::Auth::InvalidCredential) { Ask::Slack.client.channels_list }
  end

  def test_client_raises_invalid_credential_on_token_revoked
    token = "revoked_token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name == "slack_token" }]
    end

    Slack::Web::Client.any_instance.stubs(:channels_list).raises(
      Slack::Web::Api::Errors::TokenRevoked.new("token_revoked")
    )

    assert_raises(Ask::Auth::InvalidCredential) { Ask::Slack.client.channels_list }
  end

  def test_missing_credential_message_helpful
    Ask::Auth.configure do |config|
      config.providers = []
    end

    error = assert_raises(Ask::Auth::MissingCredential) { Ask::Slack.client }
    assert_match(/SLACK_TOKEN/, error.message)
    assert_match(/slack_token/, error.message)
  end
end
