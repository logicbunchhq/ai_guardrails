# frozen_string_literal: true

require "spec_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe AiGuardrails::Runner do
  let(:logger_output) { StringIO.new }
  let(:logger) { Logger.new(logger_output) }

  let(:provider) do
    Class.new do
      def call_model(*)
        '{ "name": "test" }'
      end
    end.new
  end

  before do
    AiGuardrails.configure do |c|
      c.logger = logger
      c.debug = true
    end
  end

  it "logs the run steps" do
    schema = { name: :string }
    runner = described_class.new(
      prompt: "hi",
      provider: provider,
      schema: schema
    )

    runner.run

    expect(logger_output.string).to include("Starting run")
    expect(logger_output.string).to include("Raw model output")
    expect(logger_output.string).to include("Run completed")
  end
end
# rubocop:enable Metrics/BlockLength
