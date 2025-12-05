# frozen_string_literal: true

require "spec_helper"

RSpec.describe AiGuardrails::Cache do
  let(:store) { build_test_store }
  let(:key) { described_class.key("prompt", { name: :string }) }

  before { described_class.configure(enabled: true, store: store, expires_in: 1) }

  describe ".fetch" do
    it "caches the result" do
      value = described_class.fetch(key, "result")
      expect(value).to eq("result")
      expect(store.read(key)).to eq("result")
    end

    it "returns cached value on repeated calls" do
      described_class.fetch(key, "first")
      value = described_class.fetch(key, "second")
      expect(value).to eq("first")
    end

    it "returns block result if caching disabled" do
      described_class.enabled = false
      value = described_class.fetch(key, "fresh")
      expect(value).to eq("fresh")
    end

    it "executes block and caches result if not present" do
      value = described_class.fetch(key, "generated")
      expect(value).to eq("generated")
      expect(store.read(key)).to eq("generated")
    end
  end
end

# helper method to reduce block length
TestStore = Class.new do
  attr_reader :data

  def initialize
    @data = {}
  end

  def read(key, **_options)
    data[key]
  end

  def write(key, value, **_options)
    data[key] = value
  end
end

def build_test_store
  TestStore.new
end
