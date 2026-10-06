# frozen_string_literal: true

module AiGuardrails
  module Provider
    # Handles actual Anthropic API calls.
    # The anthropic gem is only loaded when call_model is used.
    class AnthropicClient < BaseClient
      def initialize(config = {})
        super
        @client = nil
      end

      # Actual API call method
      def call_model(prompt:)
        ensure_provider_loaded
        @client ||= ::Anthropic::Client.new(api_key: @config[:api_key])
        extract_content(@client.messages.create(**anthropic_message_params(prompt)))
      end

      private

      # Load anthropic only when needed
      def ensure_provider_loaded
        require "anthropic"
      rescue LoadError
        raise LoadError,
              "anthropic gem is not installed. Add:\n" \
              "  gem 'anthropic', require: false\n" \
              "to your Gemfile if using Anthropic provider."
      end

      def default_model
        @config[:default_model] || "claude-3-5-sonnet-20241022"
      end

      def anthropic_message_params(prompt)
        {
          model: @config[:model] || default_model,
          max_tokens: @config[:max_tokens] || 1024,
          messages: [{ role: "user", content: prompt }]
        }
      end

      # Anthropic Ruby SDK returns objects that quack like hashes,
      # but we also support plain Hash responses for easier testing.
      def extract_content(response)
        # SDK object style: response.content is an array of blocks
        if response.respond_to?(:content)
          first_block = response.content.first
          return first_block.text if first_block.respond_to?(:text)
        end

        # Hash-style response: { "content" => [{ "text" => "..." }] }
        if response.is_a?(Hash)
          block = response.dig("content", 0)
          return block["text"] if block.is_a?(Hash) && block["text"]
        end

        nil
      end
    end
  end
end
