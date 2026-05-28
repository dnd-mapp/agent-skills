---
name: configure-issue-tracker
description: Configures local issue tracking for a repo by interviewing the user about Issue Types, fields, statuses, and settings, then writes agent-readable config files with progressive disclosure. Use when the user wants to set up or update issue tracking, says "configure issue tracker", "set up issues", "I want to track issues locally", or runs /configure-issue-tracker.
---

# Configure Issue Tracker

Sets up or updates local issue tracking for a repo. Writes config to `docs/agents/` and wires progressive disclosure into `CLAUDE.md` and `AGENTS.md`. Does **not** create or manage individual issues.

## Modes

Check first: does `docs/agents/issue-tracker.md` exist?

- **No → Init**: run the full interview, then write all output files.
- **Yes → Update**: load existing config, show a summary, ask which sections the user wants to change, re-interview only those sections.

## Workflow

1. **Check for existing config** — read `docs/agents/issue-tracker.md` if it exists.
2. **Run the interview** — see [INTERVIEW.md](INTERVIEW.md). Present defaults visibly; only drill into sub-questions when the user wants to override.
3. **Write output files** — see [OUTPUTS.md](OUTPUTS.md) for formats and templates.
4. **Confirm** — show the user a summary of what was written and where.

## Key rules

- Present all defaults visibly. Never apply a default silently.
- Never push to remote or create git commits.
- **Issue Type** (Epic, Story, Task, Bug) is different from branch `type` (Conventional Commits: `feat`, `fix`, …). Never use "type" alone when referring to Issue Types.
- Issue Number format depends on the configured numbering scheme — do not assume `#N`.
