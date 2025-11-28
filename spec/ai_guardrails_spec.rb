# frozen_string_literal: true

require "spec_helper"

RSpec.describe AiGuardrails do
  it "has a version number" do
    expect(AiGuardrails::VERSION).not_to be nil
  end
end
