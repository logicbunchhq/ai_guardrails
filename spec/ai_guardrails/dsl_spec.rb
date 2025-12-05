# frozen_string_literal: true

require "spec_helper"

class FakeProvider
  attr_reader :call_count

  # Default responses = [] so DSL can call FakeProvider.new with zero args
  def initialize(responses = [])
    @responses = responses.dup
    @call_count = 0
  end

  def call_model(*)
    @call_count += 1
    # Return a hash matching schema
    @responses.shift || { "name" => "Laptop", "price" => 1200.0 }
  end
end

RSpec.describe AiGuardrails::DSL do
  let(:schema) { { name: :string, price: :float } }

  before do
    # Stub the Factory to return our fake provider
    allow(AiGuardrails::Provider::Factory).to receive(:build).and_return(FakeProvider.new)
  end

  it "returns validated output" do
    result = described_class.run(prompt: "Generate product", schema: schema)
    expect(result).to eq(name: "Laptop", price: 1200.0)
  end

  it "raises error for unsafe content" do
    # Disable cache to ensure SafetyFilter is triggered
    AiGuardrails::Cache.enabled = false

    fake_provider = FakeProvider.new([{ "name" => "Laptop", "price" => 1200.0 }])
    allow(AiGuardrails::Provider::Factory).to receive(:build).and_return(fake_provider)

    expect do
      described_class.run(prompt: "Generate product", schema: schema, blocklist: ["laptop"])
    end.to raise_error(AiGuardrails::SafetyFilter::UnsafeContentError)

    # Re-enable cache after test if needed
    AiGuardrails::Cache.enabled = true
  end

  it "supports custom provider config" do
    expect(AiGuardrails::Provider::Factory).to receive(:build).with(provider: :openai, config: { api_key: "123" })

    described_class.run(
      prompt: "hi", provider: :openai, provider_config: { api_key: "123" }, schema: schema
    )
  end
end
