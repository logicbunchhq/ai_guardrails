# frozen_string_literal: true

require "spec_helper"
require "ai_guardrails/json_repair"

# rubocop:disable Metrics/BlockLength
RSpec.describe AiGuardrails::JsonRepair do
  let(:repairer) { described_class }

  # ---------------------------
  # Valid JSON / Repairable examples
  # ---------------------------
  valid_examples_simple = [
    '{"name":"Alice"}', # simple object
    "{'name':'Bob'}", # single quotes
    '{"name":"Charlie" "age":30}', # missing comma
    '{"user":{"name":"Dave","age":25}}', # nested object
    '{"users":[{"name":"Eve"},{"name":"Frank"}]}', # array of objects
    '{name:"Grace",age:40}', # unquoted keys
    '{"projects":[{"id":1} {"id":2}]}', # consecutive objects missing comma
    '{"name":"Heidi"}', # trailing commas removed
    '{"matrix":[[1 2][3 4]]}' # nested arrays with missing commas
  ].freeze

  valid_examples_advanced = [
    '{"user-name":"Ivan","age-years":50}', # keys with dashes
    '{"data":[[1,2],[3,4]]}', # array of arrays
    '{"active":true,"deleted":false,"metadata":null}', # boolean/null
    '{"x":10,"y":20}', # numbers
    '{"a":1, "b":2', # unbalanced braces
    '{"people":[{name:"Jack"} {name:"Jill"}]}', # mix
    '{"projects":[{"id":1,"name":"ProjA","tasks":[{"t":"T1"},
      {"t":"T2"}]},{"id":2,"name":"ProjB","tasks":[{"t":"T3"},{"t":"T4"}]}]}'
  ].freeze

  (valid_examples_simple + valid_examples_advanced).each_with_index do |raw, i|
    it "repairs valid example ##{i + 1}" do
      expect { repairer.repair(raw) }.not_to raise_error
      result = repairer.repair(raw)
      expect(result).to be_a(Hash).or be_a(Array)
    end
  end

  # ---------------------------
  # Unrecoverable examples
  # ---------------------------
  unrecoverable_examples = [
    '{"a":1} {"b":2}', # object followed by another object
    '[1,2] {"x":10}', # array followed by object
    "random text not JSON", # completely invalid
    '{"a":1} {"b":2} {"c":3}', # consecutive objects
    '{"values":[1 2 3][4 5 6]}' # consecutive arrays
  ].freeze

  unrecoverable_examples.each_with_index do |raw, i|
    it "raises RepairError for unrecoverable example ##{i + 1}" do
      expect { repairer.repair(raw) }.to raise_error(AiGuardrails::JsonRepair::RepairError)
    end
  end
end
# rubocop:enable Metrics/BlockLength
