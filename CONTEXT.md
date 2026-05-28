# Agent Skills

Skills for AI-assisted git workflows. Each skill automates a discrete developer action with consistent conventions.

## Language

### Git workflows

**Branch**: A git branch whose name follows `<type>/<issue>-<slug>`, where `<issue>` is optional. Type mirrors Conventional Commits types.  
_Avoid_: Ref, feature branch

**Slug**: A kebab-case phrase derived from a user description or inferred from working-tree changes and unpushed commits.  
_Avoid_: Label, suffix, description

### Issue tracking

**Issue**: A Markdown file at `docs/planning/issues/` representing a unit of tracked work, with a frontmatter block of structured fields and a free-form Markdown body. Scoped to local tracking; remote tracker support (GitHub, Jira) is planned.  
_Avoid_: Ticket, card, item

**Issue Type**: The user-defined classification of an Issue (e.g. Epic, Story, Task, Bug). Configured per repo. Not to be confused with the branch `type` from Conventional Commits.  
_Avoid_: Type (alone — collides with Conventional Commits branch type), kind

**Issue Number**: A unique identifier for an Issue. Format depends on the repo's configured numbering scheme: global sequential (`#42`) or project identifier (`DND-42`).  
_Avoid_: ID, ticket number

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
