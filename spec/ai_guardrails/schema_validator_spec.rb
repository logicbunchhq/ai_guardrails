# frozen_string_literal: true

require "spec_helper"

RSpec.describe AiGuardrails::SchemaValidator do
  let(:schema) { { name: :string, price: :float, tags: [:string] } }
  let(:validator) { described_class.new(schema) }

  it "validates correct input" do
    input = { name: "Laptop", price: 1200.0, tags: %w[electronics sale] }
    success, result = validator.validate(input)
    expect(success).to be true
    expect(result).to eq(input)
  end

  it "returns errors for invalid types" do
    input = { name: 123, price: "abc", tags: ["electronics", 2] }
    success, errors = validator.validate(input)
    expect(success).to be false
    expect(errors[:name]).not_to be_nil
    expect(errors[:price]).not_to be_nil
    expect(errors[:tags]).not_to be_nil
  end

  it "raises error for unsupported type in schema" do
    schema = { something: :unknown_type }
    expect { described_class.new(schema) }.to raise_error(ArgumentError)
  end
end
