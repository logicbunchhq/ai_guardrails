# frozen_string_literal: true

require "simplecov"
require "simplecov-lcov"

# Configure LCOV output for GitHub Actions.
SimpleCov::Formatter::LcovFormatter.config do |config|
  config.report_with_single_file = true
  config.output_directory = "coverage"
  config.lcov_file_name = "lcov.info"
end

# Local HTML + LCOV for CI
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::LcovFormatter
]

SimpleCov.start do
  add_filter "/spec/"
end

require "ai_guardrails"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |expect_config|
    expect_config.syntax = :expect
  end
end
