# Agent Skills

Skills for AI-assisted git workflows. Each skill automates a discrete developer action with consistent conventions.

## Language

### Git workflows

**Branch**: A git branch whose name follows `<type>/<issue>-<slug>`, where `<issue>` is optional. Type mirrors Conventional Commits types.  
_Avoid_: Ref, feature branch

**Slug**: A kebab-case phrase derived from a user description or inferred from working-tree changes and unpushed commits.  
_Avoid_: Label, suffix, description

### Issue tracking

**Issue**: A unit of tracked work whose representation depends on the configured backend. For the local backend: a Markdown file at `docs/planning/issues/` with a frontmatter block of structured fields and a free-form Markdown body. For GitHub without a Project: a GitHub Issue. For GitHub with a Project configured: a GitHub Projects item backed by a GitHub Issue.  
_Avoid_: Ticket, card, item

**Issue Type**: The user-defined classification of an Issue (e.g. Epic, Story, Task, Bug). Configured per repo. Physical representation depends on the backend and GitHub context: a frontmatter field for local; a GitHub label for GitHub (personal repo, Issues only); a Projects v2 single-select custom field for GitHub (personal repo, with Project); a GitHub org-level issue type for GitHub (org repo) — in this case the type is set on the backing GitHub Issue and is visible in any associated Project without a separate Project field. Not to be confused with the branch `type` from Conventional Commits.  
_Avoid_: Type (alone — collides with Conventional Commits branch type), kind

**Issue Field**: A structured attribute of an Issue beyond its title and body. Physical representation depends on the Tracker Backend:

- **local**: frontmatter key-value pair
- **github-issues**: enumerated fields with few distinct values → GitHub label (severity and priority labels are prefixed: `severity:S1`, `priority:P0`); iteration → label (prefixed: `iteration:Q1-2026`); numeric/reference/free-text fields → inlined in the Issue body
- **github-issues-projects**: Projects v2 custom field (single-select, number, text, or iteration type)
- **github-issues + org**: org-level issue field

_Avoid_: Attribute, property, metadata

**Issue Number**: A unique identifier for an Issue. For the local backend: format depends on the configured numbering scheme — global sequential (`#42`) or project identifier (`DND-42`). For the GitHub backend: the GitHub Issue number (`#42`), always repo-scoped and assigned by GitHub. When a GitHub Project is configured, the Project item must be backed by a GitHub Issue, so the Issue Number is still the GitHub Issue number.  
_Avoid_: ID, ticket number

**Tracker Backend**: The configured storage and service mechanism for Issues. Current supported values: `local` (Markdown files), `github-issues` (GitHub Issues only), `github-issues-projects` (GitHub Issues backed by a GitHub Project). Jira support is planned.  
_Avoid_: Backend (alone — too generic), integration, provider

### Pull Requests

**Pull Request**: A Branch submitted for peer review and merge into a target branch, created via `gh pr create`. A Pull Request may be a draft (open but not yet ready for review) or a ready-for-review PR. When the Branch name contains an Issue Number, the Pull Request body should reference it using a `Closes #<n>` keyword if the PR template provides a section for it.  
_Avoid_: PR (in documentation — spell it out), Merge Request, Review Request

**PR Template**: A Markdown file that provides a structured body skeleton for Pull Requests. Detected at two levels: repo-level (`.github/PULL_REQUEST_TEMPLATE.md` or `.github/PULL_REQUEST_TEMPLATE/` for multiples) and org-level (`<org>/.github` repository, same paths). Repo-level takes precedence when both exist. Selected once during the `pull-request` skill interview and stored in agent config.  
_Avoid_: Template, body template (collides with Issue body template)

### Agent configuration

**Agent config**: Operational documentation stored under `docs/agents/` that skills read to perform repo-specific tasks. Distinct from `CONTEXT.md` (domain glossary) and `CLAUDE.md` (session bootstrap).  
_Avoid_: Agent instructions, agent context

## Relationships

- A **Branch** contains one or more commits
- A **Branch** name is composed of a type, an optional **Issue Number**, and a **Slug**
- An **Issue** has exactly one **Issue Type**
- An **Issue** has exactly one **Issue Number**
- An **Issue Type** defines the fields, allowed statuses, and body template for its **Issues**
- **Agent config** files live under `docs/agents/` and are surfaced to skills via progressive disclosure from `AGENTS.md`

## Example dialogue

> **Dev:** "I made some changes directly on `main` — can you create a branch for this?"  
> **Skill:** "I see unpushed commits referencing `Closes #42`. Proposing `feat/42-add-oauth-login` — does that look right?"  
> **Dev:** "Yes."  
> **Skill:** "`git checkout -b feat/42-add-oauth-login` done."

> **Dev:** "Create a Story for adding OAuth login."  
> **Skill:** "I see the issue tracker is configured with Story, Task, and Bug types. Proposing `docs/planning/issues/0003-story-add-oauth-login.md` with status `open`. Does that look right?"  
> **Dev:** "Yes."

## Flagged ambiguities

- "type" is used in two unrelated contexts: the Conventional Commits `type` in branch names (`feat`, `fix`, …) and **Issue Type** (Epic, Story, Task, Bug). Always qualify as **Issue Type** when referring to the latter.
