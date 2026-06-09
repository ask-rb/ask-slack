# frozen_string_literal: true

require_relative "test_helper"

class ErrorGuideTest < Minitest::Test
  def test_rate_limit_has_error_class
    assert_equal "Slack::Web::Api::Errors::TooManyRequestsError", Ask::Slack::Errors::RATE_LIMIT[:error_class]
  end

  def test_rate_limit_has_retry_action
    assert_includes Ask::Slack::Errors::RATE_LIMIT[:action], "Retry-After"
  end

  def test_errors_cover_common_slack_errors
    %w[
      not_authed
      invalid_auth
      account_inactive
      token_revoked
      token_expired
      rate_limited
      channel_not_found
      user_not_found
      not_in_channel
      restricted_action
      missing_scope
      internal_error
    ].each do |error_key|
      assert Ask::Slack::Errors::ERRORS.key?(error_key), "Missing error #{error_key}"
    end
  end

  def test_for_returns_guidance
    guidance = Ask::Slack::Errors.for("channel_not_found")
    assert guidance.key?(:message)
    assert guidance.key?(:action)
  end

  def test_for_returns_nil_for_unknown
    assert_nil Ask::Slack::Errors.for("some_unknown_error")
  end

  def test_error_messages_are_helpful
    error = Ask::Slack::Errors.for("invalid_auth")
    assert_includes error[:action], "xoxb-"
  end

  def test_status_codes_cover_common_codes
    [200, 201, 204, 400, 401, 403, 404, 429, 500, 502, 503].each do |code|
      assert Ask::Slack::Errors::STATUS_CODES.key?(code), "Missing status code #{code}"
    end
  end

  def test_status_code_description_returns_string
    desc = Ask::Slack::Errors.status_code_description(404)
    assert_match(/Not Found/, desc)
  end

  def test_status_code_description_returns_nil_for_unknown
    assert_nil Ask::Slack::Errors.status_code_description(999)
  end

  def test_pagination_info_is_defined
    assert Ask::Slack::Errors::PAGINATION.key?(:cursor_based)
    assert Ask::Slack::Errors::PAGINATION.key?(:limit)
    assert Ask::Slack::Errors::PAGINATION.key?(:pattern)
  end

  def test_exception_classes_cover_common_errors
    %w[
      not_authed
      invalid_auth
      account_inactive
      token_revoked
      token_expired
      rate_limited
      channel_not_found
      user_not_found
    ].each do |error_string|
      assert Ask::Slack::Errors::EXCEPTION_CLASSES.key?(error_string), "Missing exception class mapping #{error_string}"
    end
  end

  def test_exception_class_returns_string
    klass = Ask::Slack::Errors.exception_class("rate_limited")
    assert_equal "Slack::Web::Api::Errors::TooManyRequestsError", klass
  end

  def test_exception_class_returns_nil_for_unknown
    assert_nil Ask::Slack::Errors.exception_class("bogus_error")
  end
end
