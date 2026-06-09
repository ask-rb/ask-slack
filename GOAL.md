# ask-slack — Uslack Service Context

## Purpose

Service context gem for Uslack. Provides three files:
- `context.rb` — metadata for the system prompt (API docs, auth instructions, quick-start code snippets)
- `client.rb` — authenticated API client helper
- `error_guide.rb` — structured error knowledge for agents

No tool classes. The agent reads the context from the system prompt, writes Ruby code using the `client` helper, and executes it with the `Code` tool from `ask-tools-shell`.

## Dependencies

- **Runtime:**
  - `ask-auth` (for `Ask::Auth.resolve(:service_token)`)
  - `Uslack` API client gem (e.g., `slack-ruby-client`, `notion-ruby`, `linear-ruby`)
- **Build/test:** minitest, mocha, rake, vcr, webmock
- **This gem MUST wait until `ask-auth` is built, tested, and released.** The client helper depends on `Ask::Auth.resolve`.

## Implementation Steps

### 1. Define the gem scaffold
- `lib/ask-slack.rb` — entry point
- `lib/ask/slack.rb` — module
- `lib/ask/slack/version.rb`
- `lib/ask/slack/context.rb` — metadata constants
- `lib/ask/slack/client.rb` — authenticated client helper
- `lib/ask/slack/error_guide.rb` — structured error knowledge
- `ask-slack.gemspec` — depends on `ask-auth`, the service's official Ruby client

### 2. Research the service's API
- Find the official API docs URL
- Find if there's an OpenAPI spec
- Identify the auth mechanism (API key, OAuth, personal token)
- Identify the official Ruby client gem
- Determine common operations agents would need
- Map common error responses and their meanings

### 3. Build context.rb
Define constants following the `ask-github` pattern: `DESCRIPTION`, `DOCS_URL`, `OPENAPI_URL` (if available), `AUTH_NAME`, `AUTH_HOW`, `GEM_NAME`, `GEM_DOCS`, `QUICK_START`.

### 4. Build client.rb
- `Ask::Uslack.client` returns an authenticated client
- Resolves token via `Ask::Auth.resolve(:service_token)`
- Raises `Ask::Auth::MissingCredential` with instructions if no token found
- Configures sensible defaults (pagination, timeout, user agent)

### 5. Build error_guide.rb
- Map of common error patterns
- Rate limit info
- Pagination info
- Common HTTP status codes and their meanings

### 6. Test coverage
- Test context constants are accessible and correct
- Test client returns authenticated client
- Test client raises appropriate errors when credentials missing or invalid
- Test error guide maps are accurate

### 7. README
- Quick start: `Ask::Uslack.client` and writing agent code
- Auth setup instructions
- Common usage patterns
- How to develop and test locally

## What "Done" Means

- `Ask::Uslack.client` returns authenticated API client
- Context constants provide all metadata an agent needs
- Error guide provides actionable recovery info
- Tests pass with mocked credentials and API responses
- Following the `ask-github` template exactly (it's the reference implementation)
- README documents auth setup and common patterns
