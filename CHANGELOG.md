# Changelog

All notable changes to this project will be documented in this file.
See [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

- Placeholder for future changes

## [1.2.0] - 2025-12-12
### Added
- Final improvements and documentation updates
- Minor formatting improvements in README.md

### Changed
- None

### Fixed
- None

## [1.1.0] - 2025-12-11
### Added
- JSON + Schema Auto-Fix Hooks (`AiGuardrails::AutoFix`) with DSL integration
- RSpec tests for schema auto-fix and hooks
- Documentation for JSON + Schema Auto-Fix Hooks

### Changed
- `AiGuardrails::DSL` integrated JSON + Schema Auto-Fix Hooks

### Fixed
- None

## [1.0.0] - 2025-12-05
### Added
- Optional caching layer (`AiGuardrails::Cache`) with DSL integration
- RSpec tests for caching behavior
- Documentation for Optional Caching usage

### Changed
- DSL fixes for caching integration

### Fixed
- Minor Rubocop offenses in specs

## [0.9.0] - 2025-12-04
### Added
- Background Job and CLI-friendly helpers (`AiGuardrails::BackgroundJob` and `AiGuardrails::CLI`)
- RSpec tests for background job and CLI helpers
- Documentation for Background Job / CLI usage

### Changed
- Minor Rubocop fixes

### Fixed
- None

## [0.8.0] - 2025-12-04
### Added
- Easy DSL / Developer-Friendly API (`AiGuardrails::DSL`) for running LLM workflows
- RSpec tests for DSL

### Changed
- AutoCorrection initializer fixes for tests

### Fixed
- None

## [0.7.0] - 2025-12-03
### Added
- Logging & debug support across pipeline (`AiGuardrails::Logger`, `AiGuardrails::Runner`, `AiGuardrails::Config`)
- RSpec tests for logger and runner

### Changed
- Spec files reorganized under `ai_guardrails` namespace

### Fixed
- Minor Rubocop offenses

## [0.6.0] - 2025-12-03
### Added
- Safety & content filters (`AiGuardrails::SafetyFilter`) to detect unsafe or blocked content
- RSpec tests for safety filter
- Documentation for Safety & Content Filters

### Changed
- None

### Fixed
- None

## [0.5.0] - 2025-12-03
### Added
- Auto-Correction / Retry layer for AI calls with JSON repair and schema validation (`AiGuardrails::AutoCorrection`)
- RSpec tests for Auto-Correction / Retry layer
- Documentation for Auto-Correction / Retry usage

### Changed
- Minor Rubocop fixes

### Fixed
- None

## [0.4.0] - 2025-12-02
### Added
- Provider-agnostic API for LLMs (`AiGuardrails::Provider::BaseClient`, `OpenAIClient`, Factory)
- RSpec tests for Provider-Agnostic API
- Documentation for LLM Provider API

### Changed
- Lazy-load OpenAI gem in `OpenAIClient`

### Fixed
- None

## [0.3.0] - 2025-12-02
### Added
- Unit Test Helpers / Mock Model Client (`AiGuardrails::MockModelClient`)
- RSpec tests for MockModelClient
- Documentation for unit test helpers

### Changed
- Minor Rubocop fixes

### Fixed
- None

## [0.2.0] - 2025-12-01
### Added
- Automatic JSON Repair (`AiGuardrails::JSONRepair`) with specs
- Documentation for Automatic JSON Repair
- Byebug gem added for debugging

### Changed
- Refactored JSONRepair for Rubocop compliance and edge cases

### Fixed
- Nil and malformed JSON handling

## [0.1.0] - 2025-11-28
### Added
- Initial release
- Schema Validation (`AiGuardrails::SchemaValidator`) with RSpec tests
- Documentation for Schema Validation

### Changed
- None

### Fixed
- Rubocop offenses in initial scaffold
