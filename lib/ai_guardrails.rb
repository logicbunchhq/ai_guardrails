# frozen_string_literal: true

require_relative "ai_guardrails/version"
require_relative "ai_guardrails/config"

require_relative "ai_guardrails/schema_validator"
require_relative "ai_guardrails/json_repair"
require_relative "ai_guardrails/mock_model_client"

require_relative "ai_guardrails/provider/base_client"
require_relative "ai_guardrails/provider/openai_client"
require_relative "ai_guardrails/provider/factory"

require_relative "ai_guardrails/auto_correction"
require_relative "ai_guardrails/safety_filter"
require_relative "ai_guardrails/logger"
require_relative "ai_guardrails/runner"
require_relative "ai_guardrails/dsl"

# Main namespace for the AiGuardrails gem.
module AiGuardrails
  class Error < StandardError; end

  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield(config)

      Logger.logger = config.logger
      Logger.debug_mode = config.debug
    end
  end
end
