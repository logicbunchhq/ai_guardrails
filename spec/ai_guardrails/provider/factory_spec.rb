# frozen_string_literal: true

require "spec_helper"

RSpec.describe AiGuardrails::Provider::Factory do
  describe ".build" do
    it "returns an OpenAIClient instance" do
      client = described_class.build(provider: :openai, config: { api_key: "test" })
      expect(client).to be_an(AiGuardrails::Provider::OpenAIClient)
    end

    it "raises error for unknown provider" do
      expect { described_class.build(provider: :unknown) }.to raise_error(ArgumentError, /Unknown provider/)
    end
  end
end
