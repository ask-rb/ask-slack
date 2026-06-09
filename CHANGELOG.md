# Changelog

## [0.1.0] — Unreleased

### Added

- Initial release of `ask-slack` — Slack service context for the ask-rb ecosystem.
- **context.rb** — Metadata constants for AI system prompts: `DESCRIPTION`, `DOCS_URL`, `OPENAPI_URL`, `AUTH_NAME`, `AUTH_HOW`, `GEM_NAME`, `GEM_VERSION`, `GEM_DOCS`, `QUICK_START`
- **client.rb** — `Ask::Slack.client` returns an authenticated `Slack::Web::Client` via `Ask::Auth.resolve(:slack_token)`. Wraps client in `ClientProxy` to convert `NotAuthed`, `InvalidAuth`, `AccountInactive`, `TokenRevoked`, and `TokenExpired` errors to `Ask::Auth::InvalidCredential`.
- **error_guide.rb** — `Ask::Slack::Errors` with rate limit info, HTTP status code descriptions, Slack API error string guidance map, exception class mappings, and pagination info for agents.
- **Dependencies:** `ask-auth ~> 0.1`, `slack-ruby-client ~> 3.1`
- **Testing:** 29 tests, 81 assertions covering context constants, client auth flow, and error guide lookups.
