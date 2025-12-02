# frozen_string_literal: true

module AiGuardrails
  module Provider
    # Factory returns the right provider client
    class Factory
      PROVIDERS = {
        openai: OpenAIClient
        # add :anthropic => AnthropicClient later
      }.freeze

      def self.build(provider:, config: {})
        klass = PROVIDERS[provider.to_sym]
        raise ArgumentError, "Unknown provider: #{provider}" unless klass

        klass.new(config)
      end
    end
  end
end
