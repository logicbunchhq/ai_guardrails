# frozen_string_literal: true

require "spec_helper"

RSpec.describe AiGuardrails::BackgroundJob do
  let(:logger_output) { StringIO.new }

  let(:string_logger) do
    Logger.new(logger_output).tap do |log|
      log.formatter = proc { |_s, _d, _p, msg| "#{msg}\n" }
    end
  end

  describe "logger setup" do
    it "temporarily overrides logger and restores the old one" do
      previous_logger = AiGuardrails::Logger.logger
      previous_debug = AiGuardrails::Logger.debug_mode

      described_class.perform(logger: string_logger, debug: true) do
        AiGuardrails::Logger.info("Inside")
      end

      expect(logger_output.string).to include("Inside")
      expect(AiGuardrails::Logger.logger).to eq(previous_logger)
      expect(AiGuardrails::Logger.debug_mode).to eq(previous_debug)
    end
  end
end

RSpec.describe AiGuardrails::BackgroundJob, "successful execution" do
  let(:logger_output) { StringIO.new }

  let(:string_logger) do
    Logger.new(logger_output).tap do |log|
      log.formatter = proc { |_s, _d, _p, msg| "#{msg}\n" }
    end
  end

  it "returns the block result" do
    result = described_class.perform(logger: string_logger) do
      "done"
    end

    expect(result).to eq("done")
  end
end

RSpec.describe AiGuardrails::BackgroundJob, "error handling" do
  let(:logger_output) { StringIO.new }

  let(:string_logger) do
    Logger.new(logger_output).tap do |log|
      log.formatter = proc { |_s, _d, _p, msg| "#{msg}\n" }
    end
  end

  it "logs and re-raises errors" do
    expect do
      described_class.perform(logger: string_logger) do
        raise "Boom"
      end
    end.to raise_error(RuntimeError, "Boom")

    expect(logger_output.string).to include("Background job failed")
  end
end
