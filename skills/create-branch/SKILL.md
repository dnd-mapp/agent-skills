---
name: create-branch
description: Infers a branch name from working-tree changes and unpushed commits, then creates and checks out the branch. Use when the user wants to create a branch, says "create a branch", "branch this", or needs to name a branch for work in progress.
---

# Create Branch

Derives a structured branch name from context and executes `git checkout -b`. Never pushes to remote.

## Workflow

1. **Collect context** — run all four in parallel:

   - `git diff HEAD` (tracked modifications)
   - `git diff --cached` (already staged)
   - `git status --short` (untracked files)
   - `git log @{u}..HEAD --format="%s%n%b"` (unpushed commit messages and trailers) — if this fails because no upstream is configured, treat it as empty and continue

   If all four return empty and the user provided no description, ask for a description before continuing.

2. **Extract issue number** — in priority order:

   1. Parse trailers from unpushed commits (`Fixes #N`, `Closes #N`, `Refs #N`)
   2. Look for an issue number in the current conversation
   3. Ask the user

3. **Propose branch name** — derive `<type>/<issue>-<slug>` (issue optional):

   - **type**: infer from the nature of the changes (same set as Conventional Commits: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`, `build`, `perf`, `style`, `revert`). If the user provided a description, let it override.
   - **issue**: from step 2, omit if not found.
   - **slug**: kebab-case phrase summarizing the work, **strictly ≤ 40 characters** — rewrite internally until it fits. Derive from the user's description if provided, otherwise from the changes.

4. **Validate and fix** — run [validate.sh](validate.sh):

   - If exit 0: name is valid, continue.
   - If exit 1: read the `VIOLATION:` lines from stderr. Apply fixes — use the mechanically-fixed stdout as a starting point, then apply intelligent rewrites for violations that require judgment (e.g., slug too long). Re-run the script on the corrected name. Repeat until exit 0.

   Never present a name that has not passed validation.

5. **Present and confirm** — show the proposed branch name. Allow the user to edit before proceeding. Do not execute until confirmed.

6. **Check for conflicts** — run `git branch --list <name>`. If the branch already exists, surface the conflict and ask the user whether to switch to it or choose a different name.

7. **Execute** — run `git checkout -b <name>`.

## Defaults

| Concern             | Default                                        | Override                     |
|:--------------------|:-----------------------------------------------|:-----------------------------|
| Input source        | Inferred from working-tree changes and commits | User-provided description    |
| Base branch         | Current HEAD                                   | —                            |
| Issue number        | Extracted from commit trailers                 | User-provided in description |
| Push after creation | Never                                          | —                            |
