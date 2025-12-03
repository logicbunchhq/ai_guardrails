# frozen_string_literal: true

module AiGuardrails
  # SafetyFilter checks AI outputs for unsafe or unwanted content
  class SafetyFilter
    class UnsafeContentError < StandardError; end

    # Initialize with optional list of banned words or regex patterns
    def initialize(blocklist: [])
      # convert all items to regex for easier matching
      @blocklist = blocklist.map do |item|
        item.is_a?(Regexp) ? item : /\b#{Regexp.escape(item)}\b/i
      end
    end

    # Checks the content
    # Raises UnsafeContentError if any blocked content is detected
    def check!(content)
      @blocklist.each do |pattern|
        raise UnsafeContentError, "Unsafe content detected: #{pattern}" if content.match?(pattern)
      end
      true
    end

    # Returns boolean instead of raising
    def safe?(content)
      check!(content)
      true
    rescue UnsafeContentError
      false
    end
  end
end
