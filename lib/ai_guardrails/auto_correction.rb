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
    # Returns validated hash (symbolized keys and correct types)
    # rubocop:disable Metrics/MethodLength
    def call(prompt:, schema_hint: nil)
      attempts = 0

      # Append schema hint to prompt if provided
      prompt = prepare_prompt(prompt, schema_hint)

      loop do
        attempts += 1

        # Call AI provider
        raw_output = @provider.call_model(prompt: prompt)

        # Repair JSON if needed
        input_for_validation = parse_and_repair(raw_output)

        # Validate against schema
        valid, result = @validator.validate(input_for_validation)
        puts "valid: #{valid}, result: #{result.inspect}"

        return result if valid

        # Raise error if max retries reached
        raise RetryLimitReached, "Max retries reached" if attempts >= @max_retries

        # Log retry attempt
        puts "[AiGuardrails] Attempt #{attempts}: Invalid output, retrying..."
        sleep @sleep_time
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    # Prepare prompt with schema hint if provided
    def prepare_prompt(prompt, schema_hint)
      return prompt unless schema_hint

      "#{prompt}\n\nReturn only a valid JSON object matching this schema " \
      "(no explanations, no formatting): #{schema_hint}"
    end

    # Parse and repair raw AI output
    def parse_and_repair(raw_output)
      repaired = repair_json(raw_output)
      parse_json_or_empty(repaired)
    end

    # Attempt to repair JSON using JsonRepair
    def repair_json(raw)
      JsonRepair.repair(raw)
    rescue JsonRepair::RepairError
      raw
    end

    # Parse string JSON or return hash, fallback to empty hash
    def parse_json_or_empty(input)
      return input if input.is_a?(Hash)

      JSON.parse(input)
    rescue JSON::ParserError
      {}
    end
  end
end
