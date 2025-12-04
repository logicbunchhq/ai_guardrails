# frozen_string_literal: true

module AiGuardrails
  # Provides a simple developer-friendly interface
  module DSL
    class << self
      # Run AI model with validation, retries, and safety checks.
      def run(prompt:, schema:, **options)
        provider        = options.fetch(:provider, :openai)
        provider_config = options.fetch(:provider_config, {})
        max_retries     = options.fetch(:max_retries, 3)
        sleep_time      = options.fetch(:sleep_time, 0)
        blocklist       = options.fetch(:blocklist, [])

        client = build_client(provider, provider_config)
        result = run_with_retries(client, schema, prompt, max_retries, sleep_time)

        check_safety(result, blocklist)

        result
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

        SafetyFilter
          .new(blocklist: blocklist)
          .check!(result.to_s)
      end
    end
  end
end
