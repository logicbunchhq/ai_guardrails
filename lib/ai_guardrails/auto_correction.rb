# frozen_string_literal: true

module AiGuardrails
  # AutoCorrection handles retries, JSON repair, and schema validation
  class AutoCorrection
    class RetryLimitReached < StandardError; end

    # Initialize with a provider client and schema
    # options:
    #   max_retries: number of attempts (default: 3)
    #   sleep_time: seconds to wait between retries (default: 0)
    def initialize(provider:, schema:, max_retries: 3, sleep_time: 0)
      @provider = provider
      @validator = SchemaValidator.new(schema)
      @max_retries = max_retries
      @sleep_time = sleep_time
    end

    # Call the AI model with prompt
    # Returns validated hash
    # rubocop:disable Metrics/MethodLength
    def call(prompt:)
      attempts = 0

      loop do
        attempts += 1
        raw_output = @provider.call_model(prompt: prompt)

        # Try to repair JSON first
        begin
          repaired = JsonRepair.repair(raw_output)
        rescue JsonRepair::RepairError
          repaired = raw_output # if cannot repair, use raw
        end

        # Validate against schema
        valid, result = @validator.validate(repaired)

        return result if valid

        raise RetryLimitReached, "Max retries reached" if attempts >= @max_retries

        sleep @sleep_time
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
