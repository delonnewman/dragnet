# AGENTS.md

Guidance for AI coding agents working in this repository.

## Project Overview

Dragnet is a Rails 7.2 survey-builder and form-submission application using Ruby 3.4.9 and PostgreSQL.

Most UI is Rails views with Bootstrap 5, HTMX, and helper-driven markup. Domain code is organized under the `Dragnet::` namespace and favors small service objects, presenters, concerns, and explicit composition over large model/controller classes.

## Setup And Common Commands

```bash
bundle install
bin/rails db:setup
```

Use these commands while developing:

```bash
bundle exec rake
bundle exec rspec spec/path/to/spec.rb
bundle exec rubocop
bundle exec brakeman -q -w2
bundle exec rake bundle:audit:update bundle:audit:check
bin/rails server
bin/dev             # also starts the component watcher via Procfile.dev
```

Notes:

- `bundle exec rake` runs the default RSpec suite.
- The CI backend workflow loads the schema and seeds with `bundle exec rails db:schema:load db:seed` before running tests.
- PostgreSQL is required for test and development environments.
- The `.rspec` file enables documentation format by default.

## Architecture Notes

### Domain Model

Core survey concepts live under the `Dragnet::` namespace:

- `Dragnet::Survey` has many questions and replies. Surveys belong to a user author.
- `Dragnet::Question` has a `type_class` and optional question options.
- `Dragnet::Reply` represents a form submission and has many answers.
- `Dragnet::Answer` delegates value behavior to the question type.

### Question Types

Question types derive from `Dragnet::Type`.

The main hierarchy is:

```text
Dragnet::Type
  Basic
    Countable
      Number
        Integer
        Decimal
      Text
        LongText
      Choice
  Temporal
    Date
    Time
    DateAndTime
  Boolean
```

Custom extension types live in `app/extensions/`: `Dragnet::Ext::Address`, `Dragnet::Ext::Email`, `Dragnet::Ext::Phone`, and `Dragnet::Ext::Link`.

Types declare service objects with `perform :action_name, class_name: '...'` and can opt out with `ignore :action_name`.

### Advising And Composition

`ApplicationRecord` extends `Dragnet::Advising`. Models compose service objects with the `with` macro:

```ruby
with ReplySubmissionPolicy, delegating: %i[can_submit_reply? can_preview?]
```

The composed object is exposed as a method named after the class in snake case. Use this pattern for cross-cutting behavior such as policies, caches, and submission logic instead of adding too much behavior directly to Active Record models.

Standalone policy objects should inherit from `Dragnet::Policy` (in `lib/dragnet/policy.rb`), which itself extends `Dragnet::Composed`.

### Presenters

Models include `Dragnet::Presentable`. Calling `model.present` returns `#{ClassName}Presenter.new(model)` by convention.

Presenters inherit from `Dragnet::Presenter` or `Dragnet::PagedPresenter` and declare what they present, for example:

```ruby
presents SomeClass, as: :name
```

## Coding Conventions

- Start every Ruby file with `# frozen_string_literal: true`.
- Namespace models, presenters, helpers, and library classes under `Dragnet::` unless the surrounding code clearly does otherwise.
- `ApplicationRecord` uses `Dragnet::Memoizable`; use `memoize :method_name`, not `memoize_all`.
- Use the `Authenticated` concern for controllers that require login instead of inline authentication callbacks.
- Use `Retractable` for soft-delete behavior and `retract_associated :association_name` for cascades.
- Reuse shared RSpec examples from `spec/support/`, including `retractable`, `resumable`, `'an abstract class'`, and `'an action'` examples where applicable.
- Multi-line arrays and hashes should include trailing commas.
- RuboCop allows either nested or compact module/class syntax because `Style/ClassAndModuleChildren` is disabled.
- Keep changes small and cohesive. Prefer explicit dependencies and single-responsibility objects.

## Testing Expectations

- Add or update RSpec coverage for substantive behavior changes.
- Prefer focused specs close to the behavior being changed: model specs for domain behavior, request specs for HTTP behavior, presenter specs for presenter behavior, and lib specs for library code.
- Run the narrowest relevant spec first, then `bundle exec rake` when feasible.
- If a command cannot be run because services, dependencies, or credentials are unavailable, report that clearly in the final response.

## Security And Quality Checks

Before finishing larger changes, run the relevant checks when feasible:

```bash
bundle exec rubocop
bundle exec brakeman -q -w2
bundle exec rake bundle:audit:update bundle:audit:check
```

Do not silence security or lint findings without explaining why the suppression is safe.

## Agent Workflow

- Inspect existing patterns before editing.
- Do not overwrite unrelated user changes.
- Avoid destructive Git commands unless explicitly requested.
- Prefer minimal diffs over broad rewrites.
- Explain risky assumptions and environment prerequisites.
- When reviewing code, prioritize bugs, regressions, missing tests, security issues, and maintainability risks before summaries.
