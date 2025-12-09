# frozen_string_literal: true

require "json"

module AiGuardrails
  # Automatically fixes JSON outputs based on schema hints
  module AutoFix
    class << self
      # Fix a JSON string or hash according to schema
      #
      # @param json_input [String, Hash] raw JSON output
      # @param schema [Hash] expected schema (key => type)
      # @param hooks [Array<Proc>] optional hooks for custom fixes
      # @return [Hash] fixed output
      def fix(json_input, schema:, hooks: [])
        data = parse_json(json_input)

        fixed = apply_schema_fixes(data, schema)

        hooks.each do |hook|
          fixed = apply_hook(fixed, hook)
        end

        fixed
      end

      def apply_hook(fixed, hook)
        result = hook.call(fixed)

        # Ensure hook returns a Hash
        if result.is_a?(Hash)
          result
        else
          warn_hook_return_type(hook, result)
          fixed # keep previous hash
        end
      end

      private

      def warn_hook_return_type(hook, result)
        warn(
          "[AiGuardrails::AutoFix] WARNING: hook #{hook} returned " \
          "#{result.class}, expected Hash. Using previous hash instead."
        )
      end

      # Parse string or return hash
      def parse_json(input)
        case input
        when String
          JSON.parse(input)
        when Hash
          input
        else
          raise ArgumentError, "Unsupported input type: #{input.class}"
        end
      rescue JSON::ParserError
        {} # fallback empty hash
      end

      # Convert/repair values according to schema types
      def apply_schema_fixes(data, schema)
        fixed = {}
        schema.each do |key, type|
          str_key = key.to_s
          value = data[str_key] || data[key.to_sym]

          fixed[str_key] = convert_value(value, type)
        end
        fixed
      end

      def convert_value(value, type)
        return value.to_s if type == :string
        return value.to_i if type == :integer
        return value.to_s.to_f if type == :float
        return !!value if type == :boolean
        return value.is_a?(Array) ? value : Array(value) if type == Array

        value
      end
    end
  end
end
