# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "test/"
  add_filter "version.rb"
  enable_coverage :branch
  minimum_coverage 90
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ask-slack"
require "minitest/autorun"
require "mocha/minitest"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path("cassettes", __dir__)
  config.hook_into :webmock
  config.filter_sensitive_data("<SLACK_TOKEN>") { ENV.fetch("SLACK_TOKEN", "xoxb-dummy-token") }
  config.default_cassette_options = { record: :once, match_requests_on: [:method, :uri, :body] }
end
