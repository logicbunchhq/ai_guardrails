# frozen_string_literal: true

require "spec_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe AiGuardrails::Logger do
  let(:string_logger) do
    logger = Logger.new(StringIO.new)
    logger.level = Logger::DEBUG
    logger
  end

  before do
    described_class.logger = string_logger
    described_class.debug_mode = false
  end

  it "logs info messages" do
    allow(string_logger).to receive(:info)
    described_class.info("test")
    expect(string_logger).to have_received(:info)
  end

  it "logs errors" do
    allow(string_logger).to receive(:error)
    described_class.error("bad")
    expect(string_logger).to have_received(:error)
  end

  it "logs debug messages only when enabled" do
    allow(string_logger).to receive(:debug)
    described_class.debug("no log")
    expect(string_logger).not_to have_received(:debug)

    described_class.debug_mode = true
    described_class.debug("log now")
    expect(string_logger).to have_received(:debug)
  end

  it "uses NullLogger when no logger provided" do
    described_class.logger = nil
    expect { described_class.info("x") }.not_to raise_error
  end
end
# rubocop:enable Metrics/BlockLength
