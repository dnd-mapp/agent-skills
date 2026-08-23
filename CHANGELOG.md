# Changelog

All notable, consumer-facing changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-08-23

### Changed

- `review-comments` skill now fetches every review thread the configured account has posted on the PR before drafting. It skips a new finding that matches an existing thread: one that's resolved, has a reply judged as fixing it, or is already open and unresolved. Matching relies on reading comprehension rather than file and line, since line numbers drift between commits. An ambiguous match is posted rather than suppressed. See ADR 0002 for the fuller rationale.

## [1.1.0] - 2026-08-18

### Added

- `review-comments` skill: runs `/code-review` against a pull request, drafts one PR-level comment plus per-finding inline comments for approval, then posts them as a single GitHub review under a configured account. Registered in the plugin manifest's `skills` list alongside `branch`, `commit`, `pr`, and `ship`.

### Changed

- Plugin manifest (`.claude-plugin/plugin.json`) now declares `displayName`, `homepage`, `repository`, and `license`.

## [1.0.0] - 2026-08-17

### Added

- `branch` skill: creates a git branch named for the work ahead, following this org's branch naming convention.
- `commit` skill: drafts Conventional Commits messages and groups changes into separate commits by intent, showing the plan for review before applying it.
- `pr` skill: drafts a pull request (title, description, related issues, and checklist) from the diff against the target branch, reviewed with you before opening it with `gh pr create`.
- `ship` skill: chains the `branch`, `commit`, and `pr` skills in order, taking the working tree to an open pull request.
- Claude Code plugin registration (`.claude-plugin/plugin.json` and `marketplace.json`), so this repo installs directly as the `dnd-mapp` plugin.

### Changed

- Repo identity (name, description, README, `CONTEXT.md`) updated to reflect its actual purpose: building Agent Skills and Subagent definitions for `dnd-mapp`.

[Unreleased]: https://github.com/dnd-mapp/agent-skills/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/dnd-mapp/agent-skills/releases/tag/v1.2.0
[1.1.0]: https://github.com/dnd-mapp/agent-skills/releases/tag/v1.1.0
[1.0.0]: https://github.com/dnd-mapp/agent-skills/releases/tag/v1.0.0
