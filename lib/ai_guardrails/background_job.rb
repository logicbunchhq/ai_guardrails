# frozen_string_literal: true

module AiGuardrails
  # Provides helper methods to run AiGuardrails in background jobs or CLI
  module BackgroundJob
    class << self
      # Executes a task safely in background or CLI
      #
      # Example usage:
      #   AiGuardrails::BackgroundJob.perform do
      #     AiGuardrails::DSL.run(prompt: "...", schema: {...})
      #   end
      #
      # Optional parameters:
      #   logger: custom logger instance
      #   debug: true/false for debug mode
      def perform(logger: nil, debug: false, &block)
        with_temp_logger(logger, debug, &block)
      rescue StandardError => e
        Logger.logger&.error("Background job failed: #{e.class} - #{e.message}")
        raise e
      end

      def with_temp_logger(temp_logger, temp_debug, &block)
        prev_logger = Logger.logger
        prev_debug = Logger.debug_mode

        Logger.logger = temp_logger if temp_logger
        Logger.debug_mode = temp_debug

        perform_with_error_logging(&block)
      ensure
        Logger.logger = prev_logger
        Logger.debug_mode = prev_debug
      end

      private

      def perform_with_error_logging(&block)
        block.call
      rescue StandardError => e
        Logger.logger&.error("Background job failed: #{e.class} - #{e.message}")
        raise e
      end
    end
  end
end
