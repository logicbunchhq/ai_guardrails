# frozen_string_literal: true

require_relative "lib/ai_guardrails/version"

Gem::Specification.new do |spec|
  spec.name = "ai_guardrails"
  spec.version = AiGuardrails::VERSION
  spec.authors = ["Faisal Raza"]
  spec.email = ["faisalraza.p@gmail.com"]

  spec.summary = "AiGuardrails: Schema validation and safety layer for AI-generated output in Ruby"
  spec.description = "AiGuardrails is a Ruby gem that helps developers validate, correct, and enforce schemas
on AI-generated outputs. It ensures structured data, prevents JSON errors, and provides
a foundation for adding safety filters and auto-correction in Rails apps, CLI tools,
background jobs, and scrapers. Think of it as Guardrails.AI for Ruby."
  spec.homepage = "https://github.com/faisalrazap/ai_guardrails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/faisalrazap/ai_guardrails"
  spec.metadata["changelog_uri"] = "https://github.com/your_username/ai_guardrails/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # Byebug is used for debugging during development and testing.
  spec.add_dependency "byebug"

  # Ensures input/output conforms to expected schema, improving reliability.
  spec.add_dependency "dry-validation", "~> 1.10"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
