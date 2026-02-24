# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe AiGuardrails::Provider::AnthropicClient do
  let(:config) do
    { api_key: "test", model: "claude-3-5-sonnet-20241022" }
  end

  describe "#initialize" do
    it "does not require anthropic until call_model is used" do
      expect { described_class.new(config) }.not_to raise_error
    end
  end

  describe "#call_model" do
    it "raises helpful error if anthropic gem missing" do
      client = described_class.new(config)

      allow(client).to receive(:require).and_raise(LoadError)

      expect do
        client.call_model(prompt: "Hello")
      end.to raise_error(LoadError, /anthropic gem is not installed/)
    end

    it "returns extracted content when provider is mocked (hash response)" do
      client = described_class.new(config)

      # Simulate gem loading successfully
      allow(client).to receive(:require).and_return(true)

      fake_anthropic = double("Anthropic::Client")
      allow(fake_anthropic).to receive_message_chain(:messages, :create).and_return(
        {
          "content" => [
            { "text" => "Hello from Claude" }
          ]
        }
      )

      stub_const("Anthropic::Client", Class.new)
      allow(Anthropic::Client).to receive(:new).and_return(fake_anthropic)

      expect(client.call_model(prompt: "Say hi")).to eq("Hello from Claude")
    end

    it "returns extracted content when provider is mocked (SDK-style object)" do
      client = described_class.new(config)

      allow(client).to receive(:require).and_return(true)

      block = double("ContentBlock", text: "SDK object response")
      response = double("Anthropic::Messages::Message", content: [block])

      messages_double = double("Messages")
      allow(messages_double).to receive(:create).and_return(response)

      fake_anthropic = double("Anthropic::Client", messages: messages_double)

      stub_const("Anthropic::Client", Class.new)
      allow(Anthropic::Client).to receive(:new).and_return(fake_anthropic)

      expect(client.call_model(prompt: "Hi")).to eq("SDK object response")
    end
  end
end
# rubocop:enable Metrics/BlockLength
