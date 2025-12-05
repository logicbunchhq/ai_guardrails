# frozen_string_literal: true

require "digest"

module AiGuardrails
  # Simple caching layer for AI responses
  module Cache
    class << self
      attr_accessor :enabled, :store, :expires_in

      # Setup cache
      # store: any object responding to #read/#write (e.g., Rails.cache, ActiveSupport::Cache)
      # expires_in: seconds
      def configure(enabled: true, store: nil, expires_in: 300)
        @enabled = enabled
        @store = store || NullStore.new
        @expires_in = expires_in
      end

      # Accept default or block, works with caching disabled
      def fetch(key, default = nil)
        return (block_given? ? yield : default) unless enabled

        cached = store.read(key, expires_in: expires_in)
        return cached if cached

        result = block_given? ? yield : default
        store.write(key, result, expires_in: expires_in)
        result
      end

      # Generate a cache key from prompt + schema
      def key(prompt, schema)
        digest_input = "#{prompt}-#{schema}"
        Digest::SHA256.hexdigest(digest_input)
      end

      # Null object if no cache store is provided
      class NullStore
        def read(_key, **_options)
          nil
        end

        def write(_key, value, **_options)
          value
        end
      end
    end
  end
end
