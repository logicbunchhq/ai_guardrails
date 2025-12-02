# frozen_string_literal: true

module AiGuardrails
  module Provider
    # Handles actual OpenAI API calls.
    # The ruby-openai gem is only loaded when call_model is used.
    class OpenAIClient < BaseClient
      def initialize(config = {})
        super
        @client = nil
      end

      # Actual API call method
      def call_model(prompt:)
        ensure_provider_loaded

        @client ||= ::OpenAI::Client.new(access_token: @config[:api_key])

        response = @client.chat(
          parameters: {
            model: @config[:model] || "gpt-4o-mini",
            messages: [{ role: "user", content: prompt }],
            temperature: @config[:temperature] || 0.7
          }
        )

        response.dig("choices", 0, "message", "content")
      end

      private

      # Load ruby-openai only when needed
      def ensure_provider_loaded
        require "ruby/openai"
      rescue LoadError
        raise LoadError,
              "ruby-openai gem is not installed. Add:\n" \
              "  gem 'ruby-openai', require: false\n" \
              "to your Gemfile if using OpenAI provider."
      end
    end
  end
end
