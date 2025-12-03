# frozen_string_literal: true

module AiGuardrails
  # Holds configuration options for AiGuardrails.
  class Config
    attr_accessor :logger, :debug

    def initialize
      @logger = nil
      @debug = false
    end
  end
end
