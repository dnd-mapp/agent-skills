# Agent Skills

Skills for AI-assisted git workflows. Each skill automates a discrete developer action with consistent conventions.

## Language

**Branch**: A git branch whose name follows `<type>/<issue>-<slug>`, where `<issue>` is optional. Type mirrors Conventional Commits types.
_Avoid_: Ref, feature branch

**Slug**: A kebab-case phrase derived from a user description or inferred from working-tree changes and unpushed commits.
_Avoid_: Label, suffix, description

## Relationships

- A **Branch** contains one or more commits
- A **Branch** name is composed of a type, an optional issue number, and a **Slug**

## Example dialogue

> **Dev:** "I made some changes directly on `main` — can you create a branch for this?"
> **Skill:** "I see unpushed commits referencing `Closes #42`. Proposing `feat/42-add-oauth-login` — does that look right?"
> **Dev:** "Yes."
> **Skill:** "`git checkout -b feat/42-add-oauth-login` done."
