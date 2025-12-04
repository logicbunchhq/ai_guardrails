# frozen_string_literal: true

require "spec_helper"

RSpec.describe AiGuardrails::CLI do
  let(:logger_output) { StringIO.new }
  let(:logger) { Logger.new(logger_output) }

  before do
    AiGuardrails::Logger.logger = logger
    AiGuardrails::Logger.debug_mode = false
  end

  it "yields to the block" do
    result = described_class.run do
      "block executed"
    end
    expect(result).to eq("block executed")
  end

  it "passes debug flag to BackgroundJob" do
    expect(AiGuardrails::BackgroundJob).to receive(:perform).with(logger: logger, debug: true)
    described_class.run(debug: true) { "ignored" }
  end

  it "logs and re-raises errors from the block" do
    expect do
      described_class.run do
        raise "CLI failure"
      end
    end.to raise_error(RuntimeError, "CLI failure")

    expect(logger_output.string).to include("Background job failed")
  end
end
