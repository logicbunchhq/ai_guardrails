# frozen_string_literal: true

module AiGuardrails
  # Simple wrapper for logging inside the gem.
  # Allows the user to pass any logger (Rails.logger, Logger.new, etc.)
  module Logger
    class << self
      attr_accessor :logger, :debug_mode

      # Logs normal information
      def info(message)
        safe_logger.info("[AiGuardrails] #{message}")
      end

      # Logs errors only
      def error(message)
        safe_logger.error("[AiGuardrails ERROR] #{message}")
      end

      # Logs extra details when debug_mode is enabled
      def debug(message)
        return unless debug_mode

        safe_logger.debug("[AiGuardrails DEBUG] #{message}")
      end

      private

      # Uses null logger if no logger is configured
      def safe_logger
        logger || NullLogger.new
      end
    end

    # Basic fallback logger that ignores messages.
    # Prevents NoMethodError when users don't set a logger.
    class NullLogger
      def info(_msg); end

      def error(_msg); end

      def debug(_msg); end
    end
  end
end
