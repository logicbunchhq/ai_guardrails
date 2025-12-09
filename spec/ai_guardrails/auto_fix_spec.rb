# frozen_string_literal: true

require "spec_helper"

RSpec.describe AiGuardrails::AutoFix do
  let(:schema) { { name: :string, price: :float, available: :boolean } }

  it "fixes valid JSON and hash inputs" do
    expect(described_class.fix('{"name":"Shirt","price":"19.99","available":"true"}', schema: schema))
      .to eq("name" => "Shirt", "price" => 19.99, "available" => true)
    expect(described_class.fix({ name: :Socks, price: "5", available: nil }, schema: schema))
      .to eq("name" => "Socks", "price" => 5.0, "available" => false)
  end

  it "applies custom hooks" do
    input = '{"name":"Hat","price":12}'
    hook = ->(h) { h.tap { |x| x["price"] *= 2 } }
    expect(described_class.fix(input, schema: schema, hooks: [hook])["price"]).to eq(24.0)
  end

  it "returns empty hash for invalid JSON" do
    expect(described_class.fix("invalid-json", schema: schema))
      .to eq("name" => "", "price" => 0.0, "available" => false)
  end

  it "ignores hooks that return invalid types" do
    input = '{"name":"Shoes","price":"20"}'
    bad_hook = ->(_h) { 123 }
    expect(described_class.fix(input, schema: schema, hooks: [bad_hook])["price"]).to eq(20.0)
  end
end
