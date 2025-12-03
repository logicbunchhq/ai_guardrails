# frozen_string_literal: true

require "spec_helper"

# Fake provider to simulate LLM responses
class FakeProvider
  attr_reader :call_count

  def initialize(responses)
    @responses = responses.dup
    @call_count = 0
  end

  def call_model(*)
    @call_count += 1
    @responses.shift || '{"name": "Default", "price": 100}'
  end
end

# rubocop:disable Metrics/BlockLength
RSpec.describe AiGuardrails::AutoCorrection do
  let(:schema) { { name: :string, price: :float } }

  it "returns valid output on first attempt" do
    provider = FakeProvider.new(['{"name": "Laptop", "price": 1200}'])
    auto = described_class.new(provider: provider, schema: schema)
    result = auto.call(prompt: "Generate product")
    expect(result).to eq(name: "Laptop", price: 1200.0)
    expect(provider.call_count).to eq(1)
  end

  it "repairs invalid JSON and returns valid output" do
    provider = FakeProvider.new(['{name: "Laptop" price: 1200}'])
    auto = described_class.new(provider: provider, schema: schema)
    result = auto.call(prompt: "Generate product")
    expect(result).to eq(name: "Laptop", price: 1200.0)
  end

  it "retries until valid output or max_retries" do
    responses = [
      '{"name": 123, "price": "abc"}', # invalid schema
      '{"name": "Laptop", "price": 1200}' # valid
    ]
    provider = FakeProvider.new(responses)
    auto = described_class.new(provider: provider, schema: schema)
    result = auto.call(prompt: "Generate product")
    expect(result).to eq(name: "Laptop", price: 1200.0)
    expect(provider.call_count).to eq(2)
  end

  it "raises RetryLimitReached after max retries" do
    responses = ['{"name": 123, "price": "abc"}'] * 5
    provider = FakeProvider.new(responses)
    auto = described_class.new(provider: provider, schema: schema, max_retries: 3)
    expect do
      auto.call(prompt: "Generate product")
    end.to raise_error(AiGuardrails::AutoCorrection::RetryLimitReached)
    expect(provider.call_count).to eq(3)
  end
end
# rubocop:enable Metrics/BlockLength
