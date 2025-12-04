# frozen_string_literal: true

module AiGuardrails
  # Provides a CLI-friendly interface for running AiGuardrails safely
  module CLI
    # Runs AiGuardrails safely in CLI scripts
    #
    # Example:
    #   AiGuardrails::CLI.run do
    #     result = AiGuardrails::DSL.run(prompt: "...", schema: {...})
    #     puts result
    #   end
    def self.run(debug: false, &block)
      BackgroundJob.perform(logger: Logger.logger, debug: debug, &block)
    end
  end
end
