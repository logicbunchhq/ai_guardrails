# frozen_string_literal: true

require "spec_helper"

RSpec.describe AiGuardrails::SafetyFilter do
  let(:blocklist) { ["badword", /forbidden/i] }
  let(:filter) { described_class.new(blocklist: blocklist) }

  describe "#check!" do
    it "raises error for blocked word" do
      expect { filter.check!("This contains badword") }
        .to raise_error(AiGuardrails::SafetyFilter::UnsafeContentError, /badword/)
    end

    it "raises error for blocked regex pattern" do
      expect { filter.check!("This is forbidden content") }
        .to raise_error(AiGuardrails::SafetyFilter::UnsafeContentError, /forbidden/i)
    end

    it "returns true for safe content" do
      expect(filter.check!("This is safe")).to eq(true)
    end
  end

  describe "#safe?" do
    it "returns false for unsafe content" do
      expect(filter.safe?("badword here")).to eq(false)
    end

    it "returns true for safe content" do
      expect(filter.safe?("All good")).to eq(true)
    end
  end
end
