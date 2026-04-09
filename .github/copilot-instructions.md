# Dragnet – Copilot Instructions

Dragnet is a Rails 7.2 survey-builder and form-submission app (Ruby 3.4.1, PostgreSQL). It has three distinct frontend layers on top of the Rails backend.

## Build, Test & Lint

### Backend (Ruby/Rails)
```bash
bundle exec rake              # run full RSpec suite (default rake task)
bundle exec rspec spec/path/to/spec.rb  # run a single spec file
bundle exec rubocop           # lint
bundle exec brakeman -q -w2   # security audit
bundle exec rake bundle:audit:update bundle:audit:check  # dependency audit
```

### ClojureScript frontends (`app/frontends/`)
```bash
npm run watch    # watch mode: editor + submitter + test builds
npm run build    # production release build (editor + submitter)
```
Builds output to `public/js/editor` and `public/js/submitter`.

### Web components (`app/components/`)
```bash
# Bun is used (see Procfile.dev)
bun build ./app/components/components --outdir ./app/assets/javascripts --watch
```

### Dev server
```bash
bin/rails server   # or use Procfile.dev which also starts the components watcher
```

---

## Architecture

### Three frontends
1. **Rails views** – most of the UI. HTMX + Bootstrap 5. Helpers in `app/helpers/` (notably `htmx_helper.rb`, `bootstrap5_helper.rb`).
2. **ClojureScript SPAs** (`app/frontends/src/main/dragnet/`) – built with shadow-cljs and React. Two apps:
   - `editor` (`dragnet.editor/-main`) – survey editing UI
   - `submitter` (`dragnet.submitter/init`) – form submission UI
   Communicate with Rails via a Transit-encoded JSON API (`/api/v1/editing/…` and `/api/v1/submission/…`).
3. **Lit web components** (`app/components/src/`) – TypeScript, built with Bun. Currently a data grid component using `@vaadin/grid`.

### Domain model (all under `Dragnet::` namespace)
- `Survey` has many `Question`s and `Reply`s (submissions). Surveys belong to a `User` (author).
- `Question` has a `type_class` (a `Dragnet::Type` subclass) and optional `QuestionOption`s.
- `Reply` represents one user's form submission; it has many `Answer`s (one per question).
- `Answer` value behaviour is delegated to the question's type.

### Question type hierarchy
`Dragnet::Type` → `Basic` → `Countable` → `Number`, `Text`, `Choice`; `Temporal` → `Date`, `Time`, `DateAndTime`; `Boolean`. Custom extension types live in `app/extensions/` (e.g. `Dragnet::Ext::Address`).

Types declare their service objects via `perform :action_name, class_name: '...'` and can opt out with `ignore :action_name`.

### Advising / composition pattern
`ApplicationRecord` extends `Dragnet::Advising`. Models compose service objects using the `with` macro:
```ruby
with ReplySubmissionPolicy, delegating: %i[can_submit_reply? can_preview?]
```
The composed object is accessible as a method named after the class (snake_cased). This is how cross-cutting behaviour (policies, caches, submission logic) is kept out of model classes.

### Presenter pattern
Models include `Dragnet::Presentable`. `model.present` returns `#{ClassName}Presenter.new(model)` (resolved by convention). Presenters inherit `Dragnet::View::Presenter` or `Dragnet::View::PagedPresenter` and declare `presents SomeClass, as: :name`.

### API layer
Routes under `/api/v1` default to `format: :transit`. The Transit gem serialises Ruby data for the ClojureScript clients. Presenters like `SurveyEditingPresenter` and `ReplySubmissionPresenter` build the Transit payloads.

---

## Key Conventions

- Every Ruby file starts with `# frozen_string_literal: true`.
- All models, presenters, helpers, and lib classes are namespaced under `Dragnet::`.
- `ApplicationRecord` uses `Dragnet::Memoizable` — call `memoize :method_name` (not `memoize_all`).
- Use `Authenticated` concern (not inline `before_action`) in controllers that require login.
- `Retractable` provides soft-delete; call `retract_associated :assoc` to cascade.
- Shared RSpec examples live in `spec/support/`; reuse `retractable_shared_examples`, `resumable_shared_examples`, etc.
- Trailing commas on multi-line arrays and hashes are enforced by RuboCop.
- `Style/ClassAndModuleChildren` is disabled – nested vs. compact module syntax is allowed.
- The `.rspec` file sets `--format documentation`, so specs print full descriptions by default.
