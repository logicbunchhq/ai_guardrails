# frozen_string_literal: true

module AiGuardrails
  # Coordinates the full validation and repair flow.
  class Runner
    def initialize(prompt:, provider:, schema:, options: {})
      @prompt = prompt
      @provider = provider
      @schema = schema
      @options = options
    end

    # rubocop:disable Metrics/MethodLength
    def run
      Logger.info("Starting run")
      Logger.debug("Prompt: #{@prompt}")

      raw = @provider.call_model(prompt: @prompt)

      Logger.debug("Raw model output: #{raw.inspect}")

      repaired_json = JsonRepair.repair(raw)
      Logger.debug("Repaired JSON: #{repaired_json.inspect}")

      valid, result = SchemaValidator.new(@schema).validate(repaired_json)

      unless valid
        Logger.error("Schema validation failed: #{result}")
        return { ok: false, errors: result }
      end

      Logger.info("Run completed successfully")
      { ok: true, result: result }
    rescue StandardError => e
      Logger.error("Unhandled exception: #{e.class} - #{e.message}")
      raise e
    end
    # rubocop:enable Metrics/MethodLength
  end
end
