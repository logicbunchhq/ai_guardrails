# frozen_string_literal: true

require "json"

module AiGuardrails
  # Repairs malformed JSON strings
  # rubocop:disable Metrics/ClassLength
  class JsonRepair
    class RepairError < StandardError; end

    # Class method entrypoint
    def self.repair(raw)
      new(raw).repair
    end

    def initialize(raw)
      @raw = raw.to_s.strip
    end

    # Main repair
    def repair
      return JSON.parse(@raw) if valid_json?(@raw)

      repaired = preprocess(@raw)
      repaired = normalize_structure(repaired)
      repaired = balance_braces(repaired)
      repaired = run_recursive_fixes(repaired)
      repaired = remove_trailing_commas(repaired)
      repaired = repaired.gsub(/\s+/, " ").strip

      raise RepairError, "Unable to repair JSON" unless valid_json?(repaired)

      JSON.parse(repaired)
    end

    private

    # --------------------------
    # JSON validation
    # --------------------------
    def valid_json?(str)
      JSON.parse(str)
      true
    rescue JSON::ParserError
      false
    end

    # --------------------------
    # Preprocessing
    # --------------------------
    def preprocess(str)
      str = str.strip
      str.gsub!("'", '"')
      str = quote_all_keys(str)
      str = insert_missing_commas_regex(str)
      remove_trailing_commas(str)
    end

    # --------------------------
    # Quote keys
    # --------------------------
    def quote_all_keys(str)
      prev = nil
      current = str.dup
      while current != prev
        prev = current
        current.gsub!(/([{\s,])([a-zA-Z0-9_-]+)\s*:/, '\1"\2":')
      end
      current
    end

    def insert_missing_commas_regex(str)
      str.gsub(/([}\]"0-9a-zA-Z])\s+("?[\w-]+"?\s*:)/, '\1, \2')
    end

    # --------------------------
    # Normalization
    # --------------------------
    def normalize_structure(input)
      repaired = input.dup
      repaired = fix_double_braces(repaired)
      repaired = fix_object_brace_spacing(repaired)
      repaired = insert_missing_commas_by_scanner(repaired)
      repaired.gsub!(/([}\]])\s*(?=([A-Za-z0-9_"-]+\s*:))/, '\1, ')
      repaired.gsub!(/([}\]])\s*(?=(\{|\[|"|\d|true|false|null))/i, '\1, ')
      repaired.gsub!(/,+/, ",")
      repaired.gsub!(/\s+/, " ")
      repaired.strip
    end

    def fix_double_braces(str)
      prev = nil
      current = str.dup
      while current != prev
        prev = current
        current.gsub!(/(\[|,)\s*\{\s*\{/, '\1 {')
      end
      current
    end

    def fix_object_brace_spacing(str)
      str.gsub(/}\s*{/, "}, {")
         .gsub(/]\s*{/, "], {")
         .gsub(/}\s*\]\s*\{/, "}], {")
    end

    # --------------------------
    # Recursive fixes runner
    # --------------------------
    def run_recursive_fixes(str)
      str = quote_all_keys(str)
      str = insert_commas_recursively(str)
      str = insert_final_commas(str)
      str = insert_commas_recursive_nested(str)
      str = fix_consecutive_objects_in_arrays(str)
      str = fix_double_object_braces(str)
      fix_adjacent_arrays(str)
    end

    def fix_adjacent_arrays(str)
      str.gsub(/\]\s*\[/, "], [")
    end

    # --------------------------
    # Scanner-based comma insertion
    # --------------------------
    def insert_missing_commas_by_scanner(str)
      s = str.dup
      out_chars = []
      i = 0
      while i < s.length
        char = s[i]
        out_chars << char
        insert_comma_after_close_brace?(char, s, i, out_chars)
        i += 1
      end
      out_chars.join.gsub(/,+/, ",").gsub(/\s+/, " ").strip
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def insert_comma_after_close_brace?(char, string, index, output_chars)
      return unless ["}", "]"].include?(char)

      j = index + 1
      j += 1 while j < string.length && string[j] =~ /\s/
      next_char = j < string.length ? string[j] : nil
      return unless next_char && ![",", "}", "]", ":"].include?(next_char)

      output_chars << "," if next_char =~ /[\[\]"0-9A-Za-z_-]/
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    # --------------------------
    # Recursive comma insertion
    # --------------------------
    def insert_commas_recursively(str)
      loop do
        prev = str.dup
        str.gsub!(/([}\]"0-9a-zA-Z])\s+(?=(\{|"[^"]*"|\d+|true|false|null|\[))/i, '\1, ')
        str.gsub!(/(\})\s+(?=\{)/, '\1, ')
        str.gsub!(/(\])\s+(?=\[)/, '\1, ')
        break if str == prev
      end
      str
    end

    def insert_final_commas(str)
      loop do
        prev = str.dup
        str.gsub!(/([}\]])\s+(?=("[a-zA-Z_][a-zA-Z0-9_]*"\s*:))/, '\1, ')
        str.gsub!(/([}\]])\s+(?=[{\[])/, '\1, ')
        break if str == prev
      end
      str
    end

    def insert_commas_recursive_nested(str)
      loop do
        prev = str.dup
        str.gsub!(/}\s*(?=\{)/, "}, {")
        str.gsub!(/]\s*(?=\[)/, "], [")
        str.gsub!(/([}\]])\s+(?=("[^"]+"\s*:))/, '\1, ')
        break if str == prev
      end
      str
    end

    def fix_consecutive_objects_in_arrays(str)
      loop do
        prev = str.dup
        str.gsub!(/({[^{}]*})\s*(?=\{)/, '\1, ')
        break if str == prev
      end
      str
    end

    def fix_double_object_braces(str)
      fix_double_braces(str)
    end

    def remove_trailing_commas(str)
      str.gsub(/,(\s*[}\]])/, '\1')
    end

    def balance_braces(str)
      open_braces = str.count("{")
      close_braces = str.count("}")
      open_brackets = str.count("[")
      close_brackets = str.count("]")

      str + "}" * [open_braces - close_braces, 0].max + "]" * [open_brackets - close_brackets, 0].max
    end
  end
  # rubocop:enable Metrics/ClassLength
end
