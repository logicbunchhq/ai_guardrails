# AiGuardrails

AI Guardrails is a Ruby gem for validating AI-generated outputs against schemas.


## Schema Validation

You can define a simple schema and validate AI output:

```ruby
require "ai_guardrails"

schema = { name: :string, price: :float, tags: [:string] }
validator = AIGuardrails::SchemaValidator.new(schema)

input = { name: "Laptop", price: 1200.0, tags: ["electronics", "sale"] }

success, result = validator.validate(input)
if success
  puts "Valid output: #{result}"
else
  puts "Validation errors: #{result}"
end
```

Supported types

:string

:integer

:float

:boolean

Array of strings (e.g., [:string])

Example invalid input

```
input = { name: 123, price: "abc", tags: ["electronics", 2] }
success, errors = validator.validate(input)
# errors => { name: ["must be a string"], price: ["must be a float"], tags: ["element 1 must be a string"] }


```

## Automatic JSON Repair

LLM output often produces **malformed or partially invalid JSON**.
`AiGuardrails::JsonRepair` attempts to **automatically repair common JSON issues** so you can safely parse AI responses into Ruby hashes.

### What it fixes

- Single quotes → double quotes (`'key': 'value'` → `"key": "value"`)
- Missing quotes around keys (`key: "value"` → `"key": "value"`)
- Missing commas between key-value pairs or objects
- Trailing commas before `}` or `]`
- Nested objects or arrays without commas
- Consecutive objects in arrays without commas
- Double braces (`{{ ... }}` → `{ ... }`)
- Adjacent arrays without commas (`][` → `], [`)
- Unbalanced/missing closing braces/brackets

> ⚠️ Designed primarily for **AI-generated JSON**, not arbitrary invalid JSON.

### Example Usage

```ruby
require "ai_guardrails"

raw_json = "{name: 'Laptop' price: 1200, tags: ['electronics' 'sale']}"

fixed = AiGuardrails::JsonRepair.repair(raw_json)

puts fixed
# => { "name" => "Laptop", "price" => 1200, "tags" => ["electronics", "sale"] }
```

Handling Unrepairable JSON

If the input is completely invalid and cannot be fixed:

```Ruby
begin
  AiGuardrails::JsonRepair.repair("THIS IS NOT JSON")
rescue AiGuardrails::JsonRepair::RepairError => e
  puts "Could not repair JSON: #{e.message}"
end

```

Integration with Schema Validation

You can combine JSON repair with AiGuardrails::SchemaValidator:

```Ruby
schema = { name: :string, price: :float, tags: [:string] }

raw = "{name: 'Laptop' price: '1200', tags: ['electronics' 'sale']}"

fixed_json = AiGuardrails::JsonRepair.repair(raw)

validator = AiGuardrails::SchemaValidator.new(schema)
success, result_or_errors = validator.validate(fixed_json)

if success
  puts "Validated output: #{result_or_errors}"
else
  puts "Schema errors: #{result_or_errors}"
end
```

## Unit Test Helpers / Mock Model Client

`AiGuardrails::MockModelClient` allows you to simulate AI model responses for testing purposes.  
You can define expected outputs without calling a real LLM API.

### Example Usage

```ruby
require "ai_guardrails"

mock_client = AiGuardrails::MockModelClient.new(
  "Generate product" => '{"name": "Laptop", "price": 1200}'
)

response = mock_client.call(prompt: "Generate product")
puts response
# => '{"name": "Laptop", "price": 1200}'

# Dynamically add new responses
mock_client.add_response("Generate user", '{"name": "Alice", "email": "alice@example.com"}')
puts mock_client.call(prompt: "Generate user")
# => '{"name": "Alice", "email": "alice@example.com"}'
```

### Simulate API errors

```ruby
begin
  mock_client.call(prompt: "Generate product", raise_error: true)
rescue AiGuardrails::MockModelClient::MockError => e
  puts e.message
end
# => "Simulated model error"

```

## Provider-Agnostic API

AiGuardrails is built to work with **any** LLM provider — without forcing users to install provider-specific gems.

By default, AiGuardrails ships with **zero vendor dependencies**.

You install only the provider client you actually want to use.


## Supported Providers

| Provider | External Gem Required | Status |
|---------|------------------------|--------|
| OpenAI | `ruby-openai` | ✔ Supported |
| Anthropic | `anthropic` | 🔜 Planned |
| Google Gemini | `google-genai` | 🔜 Planned |
| Groq | `groq` | 🔜 Planned |
| Ollama (local) | none | 🔜 Planned |


## How It Works

AiGuardrails loads providers dynamically.

When you call:

```ruby
client = AiGuardrails::Provider::Factory.build(provider: :openai, config: {...})


### Example: OpenAI

In your Gemfile:

```ruby
gem "ai_guardrails"
gem "ruby-openai", require: false   # optional
```

```ruby
client = AiGuardrails::Provider::Factory.build(
  provider: :openai,
  config: {
    api_key: ENV["OPENAI_API_KEY"],
    model: "gpt-4o-mini"
  }
)

response = client.call_model(prompt: "Hello!")
puts response
```

## Auto-Correction / Retry Layer

This feature ensures AI output is **valid JSON and matches your schema**.  
It automatically repairs broken JSON and retries until schema validation passes.

### Example Usage

```ruby
require "ai_guardrails"

# Any provider (OpenAI, Anthropic, etc.)
client = AiGuardrails::Provider::Factory.build(provider: :openai, config: { api_key: ENV["OPENAI_API_KEY"] })

# Schema to validate output
schema = { name: :string, price: :float }

auto = AiGuardrails::AutoCorrection.new(provider: client, schema: schema, max_retries: 3)

result = auto.call(prompt: "Generate product")
puts result
# => { "name" => "Laptop", "price" => 1200.0 }
```

## Notes:
- Retries: Configurable via max_retries.
- Sleep: You can set sleep_time between retries.
- JSON Repair: Automatically fixes common JSON issues from LLM output.
- Errors: Raises AiGuardrails::AutoCorrection::RetryLimitReached if valid output cannot be obtained.

## Safety & Content Filters

`AiGuardrails::SafetyFilter` helps detect unsafe or blocked content in AI outputs.

### Example Usage

```ruby
require "ai_guardrails"

# Create filter with blocked words or regex patterns
filter = AiGuardrails::SafetyFilter.new(blocklist: ["badword", /forbidden/i])

# Check content
begin
  filter.check!("This output contains badword")
rescue AiGuardrails::SafetyFilter::UnsafeContentError => e
  puts e.message
end
# => "Unsafe content detected: /badword/i"

# Boolean check
puts filter.safe?("All good")  # => true
puts filter.safe?("forbidden text") # => false
```

### Notes

- You can pass strings or regex patterns in blocklist.
- Can be used standalone or integrated with AutoCorrection to filter AI outputs.
- Raises UnsafeContentError for unsafe content, or use safe? for boolean checks.

## Easy DSL / Developer-Friendly API

`AiGuardrails.run` provides a single method to handle AI requests with schema validation,
auto-correction, JSON repair, safety filters, and logging.

### Basic Usage

```ruby
require "ai_guardrails"

schema = { name: :string, price: :float }

result = AiGuardrails::DSL.run(
  prompt: "Generate a product",
  schema: schema
)

puts result
# => { "name" => "Laptop", "price" => 1200.0 }
```

### Using a custom provider and API key

```ruby
result = AiGuardrails::DSL.run(
  prompt: "Generate a product",
  provider: :openai,
  provider_config: { api_key: ENV["OPENAI_API_KEY"] },
  schema: schema
)
```

### Safety filter integration

```ruby
result = AiGuardrails::DSL.run(
  prompt: "Generate a product",
  schema: schema,
  blocklist: ["Laptop", /Forbidden/i]
)
# Raises AiGuardrails::SafetyFilter::UnsafeContentError if blocked content is found
```

### Retry & Auto-Correction
The DSL automatically retries invalid AI responses and repairs JSON.
Configure retries:

```ruby
result = AiGuardrails::DSL.run(
  prompt: "Generate product",
  schema: schema,
  max_retries: 5,
  sleep_time: 1
)
```

## Background Job / CLI Friendly

AiGuardrails can safely run in **Rails background jobs** (ActiveJob, Sidekiq) or **CLI scripts**.

### Background Job Usage

```ruby
AiGuardrails::BackgroundJob.perform(logger: Rails.logger, debug: true) do
  AiGuardrails::DSL.run(
    prompt: "Generate product",
    schema: { name: :string, price: :float }
  )
end
```

### CLI Usage
```ruby
AiGuardrails::CLI.run(debug: true) do
  result = AiGuardrails::DSL.run(
    prompt: "Generate product",
    schema: { name: :string, price: :float }
  )
  puts result
end

```

#### Features:
- Handles logging and debug output
- Captures errors and logs them
- Restores previous logger/debug configuration after execution
- Works in scripts, Rails jobs, Sidekiq, or any background processing

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ai_guardrails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/ai_guardrails/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AiGuardrails project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ai_guardrails/blob/master/CODE_OF_CONDUCT.md).
