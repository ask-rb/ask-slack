# frozen_string_literal: true

require_relative "test_helper"

class SlackIntegrationTest < Minitest::Test
  def setup
    Ask::Auth.reset_configuration!
  end

  def test_auth_test
    configure_auth!
    VCR.use_cassette("auth_test", record: :none) do
      result = Ask::Slack.client(base_delay: 0).auth_test
      assert result.ok
      assert result.team
    end
  end

  def test_api_test
    configure_auth!
    VCR.use_cassette("api_test", record: :none) do
      result = Ask::Slack.client(base_delay: 0).api_test
      assert result.ok
    end
  end

  private

  def configure_auth!
    Ask::Auth.configure do |config|
      config.providers = [Ask::Auth::Providers::Env.new, Ask::Auth::Providers::File.new]
    end
  rescue Ask::Auth::MissingCredential
    skip "SLACK_TOKEN not available — set it in your environment or ~/.ask/credentials.yml"
  end
end
