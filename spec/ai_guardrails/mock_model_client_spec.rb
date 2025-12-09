# frozen_string_literal: true

require "spec_helper"

RSpec.describe AiGuardrails::MockModelClient do
  let(:client) { described_class.new("Generate product" => '{"name": "Laptop", "price": 1200}') }

  describe "#call" do
    it "returns predefined response for a prompt" do
      result = client.call(prompt: "Generate product")
      expect(result).to eq('{"name": "Laptop", "price": 1200}')
    end

    it "returns nil for unknown prompt without default_fallback" do
      expect(client.call(prompt: "Unknown prompt")).to be_nil
    end

    it "returns default fallback when prompt not found and raise_error is false or not provided" do
      expect(client.call(prompt: "Unknown prompt", default_fallback: "No response")).to eq("No response")
    end

    it "raises error when raise_error option is true" do
      expect { client.call(prompt: "Generate product", raise_error: true) }
        .to raise_error(AiGuardrails::MockModelClient::MockError, /Simulated model error/)
    end
  end

  describe "#add_response" do
    it "adds or updates responses dynamically" do
      client.add_response("New prompt", '{"success": true}')
      expect(client.call(prompt: "New prompt")).to eq('{"success": true}')
    end
  end
end
