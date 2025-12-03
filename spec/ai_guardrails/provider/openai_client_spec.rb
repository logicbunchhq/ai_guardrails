# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe AiGuardrails::Provider::OpenAIClient do
  let(:config) do
    { api_key: "test", model: "gpt-4o-mini" }
  end

  describe "#initialize" do
    it "does not require ruby-openai until call_model is used" do
      expect { described_class.new(config) }.not_to raise_error
    end
  end

  describe "#call_model" do
    it "raises helpful error if ruby-openai gem missing" do
      client = described_class.new(config)

      allow(client).to receive(:require).and_raise(LoadError)

      expect do
        client.call_model(prompt: "Hello")
      end.to raise_error(LoadError, /ruby-openai gem is not installed/)
    end

    it "returns extracted content when provider is mocked" do
      client = described_class.new(config)

      # Simulate gem loading successfully
      allow(client).to receive(:require).and_return(true)

      fake_openai = double("OpenAI::Client")
      allow(fake_openai).to receive(:chat).and_return(
        {
          "choices" => [
            { "message" => { "content" => "Hello world" } }
          ]
        }
      )

      stub_const("OpenAI::Client", Class.new)
      allow(OpenAI::Client).to receive(:new).and_return(fake_openai)

      expect(client.call_model(prompt: "Say hi")).to eq("Hello world")
    end
  end
end
# rubocop:enable Metrics/BlockLength
