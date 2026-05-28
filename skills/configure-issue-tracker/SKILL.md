---
name: configure-issue-tracker
description: Configures issue tracking for a repo by interviewing the user about Issue Types, fields, statuses, and settings, then writes agent-readable config files and provisions the configured Tracker Backend. Supports local Markdown files, GitHub Issues, and GitHub Issues + Projects. Use when the user wants to set up or update issue tracking, says "configure issue tracker", "set up issues", "I want to track issues locally", or runs /configure-issue-tracker.
---

# Configure Issue Tracker

Sets up or updates issue tracking for a repo. Writes config to `docs/agents/` and wires progressive disclosure into `CLAUDE.md` and `AGENTS.md`. For GitHub backends, also provisions labels, Project fields, and org-level Issue Types via the `gh` CLI. Does **not** create or manage individual issues.

## Modes

Check first: does `docs/agents/issue-tracker.md` exist?

- **No → Init**: run the full interview, then write all output files and provision GitHub (if applicable).
- **Yes → Update**: load existing config, show a summary, ask which sections the user wants to change, re-interview only those sections.

## Workflow

1. **Check for existing config** — read `docs/agents/issue-tracker.md` if it exists.
2. **Run the interview** — see [INTERVIEW.md](INTERVIEW.md) for the entry point and routing to backend-specific and shared interview files. Present defaults visibly; only drill into sub-questions when the user wants to override.
3. **Review & approve** — present a full summary of all decisions and all actions that will be taken (files to write, GitHub API calls to make). Wait for explicit approval before proceeding.
4. **Write output files and provision** — see [OUTPUTS.md](OUTPUTS.md) for formats and templates.
5. **Confirm** — show the user a summary of what was written and what was provisioned.

## Interview files

| File                                                                       | Purpose                                                                  |
|:---------------------------------------------------------------------------|:-------------------------------------------------------------------------|
| [INTERVIEW.md](INTERVIEW.md)                                               | Group 0: backend detection, selection, routing                           |
| [INTERVIEW-GITHUB.md](INTERVIEW-GITHUB.md)                                 | GitHub auth, org detection — runs for all GitHub backends                |
| [INTERVIEW-LOCAL.md](INTERVIEW-LOCAL.md)                                   | Local-specific: storage path, numbering, file naming, archive            |
| [INTERVIEW-GITHUB-ISSUES.md](INTERVIEW-GITHUB-ISSUES.md)                   | GitHub Issues: label mapping, field mapping, status sub-states           |
| [INTERVIEW-GITHUB-ISSUES-PROJECTS.md](INTERVIEW-GITHUB-ISSUES-PROJECTS.md) | GitHub Issues + Projects: Project selection, custom fields, Status field |
| [INTERVIEW-SHARED.md](INTERVIEW-SHARED.md)                                 | All backends: Issue Types, hierarchy, statuses, body templates           |

## Key rules

- Present all defaults visibly. Never apply a default silently.
- Never push to remote or create git commits.
- **Issue Type** (Epic, Story, Task, Bug) is different from branch `type` (Conventional Commits: `feat`, `fix`, …). Never use "type" alone when referring to Issue Types.
- For GitHub backends: authenticate exclusively via `gh` CLI. If `gh` is not configured or scopes are missing, pause the interview and guide the user before continuing.
- For GitHub backends: never make destructive writes to existing Project or org fields (e.g., deleting and recreating a single-select field to change its options). Doing so destroys all existing field values on Project items. Instead, update `docs/agents/` to reflect the intended state and emit explicit guidance on what the user needs to change manually in the GitHub UI or via `gh`.
- All GitHub writes happen after the review gate, never mid-interview. A failed API call partway through would leave the repo in a partially configured state. Batch all writes, show the full plan, and requires explicit approval before anything touches GitHub.
