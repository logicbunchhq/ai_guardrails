# frozen_string_literal: true

module AiGuardrails
  # Provides a simple developer-friendly interface
  module DSL
    class << self
      # Run AI model with validation, retries, and safety checks.
      def run(prompt:, schema:, **options)
        Cache.fetch(Cache.key(prompt, schema)) do
          result = run_with_retries(
            build_client(options.fetch(:provider, :openai), options.fetch(:provider_config, {})),
            schema, prompt, options.fetch(:max_retries, 3), options.fetch(:sleep_time, 0)
          )

          check_safety(result, options.fetch(:blocklist, []))
          result
        end
      end

      private

      # Builds the provider client
      def build_client(provider, config)
        Provider::Factory.build(provider: provider, config: config)
      end

      # Runs AutoCorrection wrapper
      def run_with_retries(client, schema, prompt, max_retries, sleep_time)
        auto = AutoCorrection.new(
          provider: client,
          schema: schema,
          max_retries: max_retries,
          sleep_time: sleep_time
        )
        auto.call(prompt: prompt)
      end

      # Applies blocklist filtering when needed
      def check_safety(result, blocklist)
        return if blocklist.empty?

        content = normalize_result(result)
        check_blocklist(content, blocklist)
      end

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
