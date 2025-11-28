# frozen_string_literal: true

require "dry-validation"

module AiGuardrails
  # The SchemaValidator builds a runtime validation contract
  # based on a simple Ruby Hash schema (e.g. { name: :string, tags: [:string] }).
  # It uses Dry::Validation under the hood and returns a uniform
  # response format: [success?, result_or_errors].
  class SchemaValidator
    attr_reader :contract

    def initialize(schema)
      @contract = build_contract(schema)
    end

    # Returns [success?, result_or_errors]
    def validate(input)
      result = contract.call(input)
      if result.success?
        [true, result.to_h]
      else
        [false, result.errors.to_h]
      end
    end

    private

    # Dynamically build Dry::Validation contract from simple hash
    # rubocop:disable Metrics/MethodLength
    def build_contract(schema_hash)
      klass = Class.new(Dry::Validation::Contract) do
        params do
          schema_hash.each do |key, type|
            case type
            when :string
              required(key).filled(:string)
            when :integer
              required(key).filled(:integer)
            when :float
              required(key).filled(:float)
            when :boolean
              required(key).filled(:bool)
            when Array
              # assume array of strings for now
              required(key).array(:string)
            else
              raise ArgumentError, "Unsupported type #{type} for key #{key}"
            end
          end
        end
      end
      klass.new
    end
    # rubocop:enable Metrics/MethodLength
  end
end
