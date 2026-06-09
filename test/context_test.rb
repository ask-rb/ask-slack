# frozen_string_literal: true

require_relative "test_helper"

class ContextTest < Minitest::Test
  def test_description_is_defined
    assert_match(/Slack/, Ask::Slack::DESCRIPTION)
  end

  def test_docs_url_is_defined
    assert Ask::Slack::DOCS_URL.start_with?("https://api.slack.com")
  end

  def test_openapi_url_is_defined
    assert Ask::Slack::OPENAPI_URL.start_with?("https://api.slack.com")
  end

  def test_auth_name_is_slack_token
    assert_equal :slack_token, Ask::Slack::AUTH_NAME
  end

  def test_auth_how_is_defined
    assert_includes Ask::Slack::AUTH_HOW, "api.slack.com/apps"
  end

  def test_gem_name_is_slack_ruby_client
    assert_equal "slack-ruby-client", Ask::Slack::GEM_NAME
  end

  def test_gem_version_is_defined
    assert_match(/~> 3\.1/, Ask::Slack::GEM_VERSION)
  end

  def test_gem_docs_is_defined
    assert Ask::Slack::GEM_DOCS.start_with?("https://rubydoc.info/gems/slack-ruby-client")
  end

  def test_quick_start_is_defined
    assert_includes Ask::Slack::QUICK_START, "Ask::Slack.client"
  end

  def test_quick_start_includes_common_methods
    %w[channels_list conversations_list chat_postMessage users_list conversations_history].each do |method|
      assert_includes Ask::Slack::QUICK_START, method
    end
  end
end
