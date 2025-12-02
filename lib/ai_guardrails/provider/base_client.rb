# frozen_string_literal: true

module AiGuardrails
  module Provider
    # BaseClient defines a common interface for all providers
    class BaseClient
      # Initialize with optional config hash
      def initialize(config = {})
        @config = config
      end

      # Call AI model with a prompt
      # Must be implemented by subclasses
      def call_model(prompt:)
        raise NotImplementedError, "Subclasses must implement call_model"
      end
    end
  end
end
