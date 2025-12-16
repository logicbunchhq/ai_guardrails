# frozen_string_literal: true

module AiGuardrails
  # Provides a simple developer-friendly interface
  module DSL
    class << self
      # Main entry point used by developers.
      # Run AI model with validation, retries, and safety checks.
      def run(prompt:, schema:, schema_hint: nil, **options)
        Cache.fetch(Cache.key(prompt, schema)) do
          result = fetch_with_retries_and_correction(prompt, schema, schema_hint, options)

          # Apply JSON + schema auto-fix when hooks are given.
          hooks = options.fetch(:auto_fix_hooks, [])
          fix_schema = schema_hint || schema
          result = apply_auto_fix(result, fix_schema, hooks) unless hooks.empty?

          check_safety(result, options.fetch(:blocklist, []))
          result
        end
      end

      private

      # Extracted to reduce run method length
      def fetch_with_retries_and_correction(prompt, schema, schema_hint, options)
        client = build_client(options.fetch(:provider, :openai), options.fetch(:provider_config, {}))
        max_retries = options.fetch(:max_retries, 3)
        sleep_time = options.fetch(:sleep_time, 0)
        run_with_retries_helper(
          client: client, schema: schema, prompt: prompt,
          max_retries: max_retries,
          sleep_time: sleep_time,
          schema_hint: schema_hint
        )
      end

      # Builds the provider client
      def build_client(provider, config)
        Provider::Factory.build(provider: provider, config: config)
      end

      # Runs AutoCorrection wrapper (max 5 parameters)
      def run_with_retries_helper(options = {})
        client      = options[:client]
        schema      = options[:schema]
        prompt      = options[:prompt]
        max_retries = options[:max_retries] || 3
        sleep_time  = options[:sleep_time] || 0
        schema_hint = options[:schema_hint]

        auto = AutoCorrection.new(
          provider: client, schema: schema, max_retries: max_retries, sleep_time: sleep_time
        )
        auto.call(prompt: prompt, schema_hint: schema_hint)
      end

      # Applies blocklist filtering when needed
      def apply_auto_fix(result, schema, hooks)
        AiGuardrails::AutoFix.fix(result, schema: schema, hooks: hooks)
      end

      # Runs safety filter when needed.
      def check_safety(result, blocklist)
        return if blocklist.empty?

        content = normalize_result(result)
        check_blocklist(content, blocklist)
      end

      # Normalizes result into a simple string for safety scanning.
      def normalize_result(result)
        case result
        when Hash
          result.values.join(" ")
        when String
          parse_json_string(result)
        else
          result.to_s
        end
      end

      # Attempt to parse string as JSON; fallback to original string if parsing fails
      def parse_json_string(str)
        parsed = JSON.parse(str)
        parsed.is_a?(Hash) ? parsed.values.join(" ") : str
      rescue JSON::ParserError
        str
      end

      # Perform case-insensitive safety check using SafetyFilter
      def check_blocklist(content, blocklist)
        content_down = content.downcase
        blocklist_down = blocklist.map(&:downcase)
        SafetyFilter.new(blocklist: blocklist_down).check!(content_down)
      end
    end
  end
end
