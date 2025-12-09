# frozen_string_literal: true

module AiGuardrails
  # MockModelClient simulates AI LLM responses for tests
  class MockModelClient
    class MockError < StandardError; end

    # Initialize with a hash of prompt => response
    def initialize(responses = {})
      @responses = responses.transform_keys(&:to_s)
    end

    # Simulates a call to the model
    # Options can include:
    # - prompt: string
    # - raise_error: boolean to simulate API failure
    def call(prompt:, raise_error: false, default_fallback: nil)
      return default_fallback if raise_error == false && !@responses.key?(prompt.to_s)

      raise MockError, "Simulated model error" if raise_error

      response = @responses[prompt.to_s]

      raise MockError, "No mock response defined for prompt: #{prompt}" unless response

      response
    end

    # Add or update mock responses dynamically
    def add_response(prompt, response)
      @responses[prompt.to_s] = response
    end
  end
end
