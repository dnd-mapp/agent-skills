---
name: pull-request
description: Pushes the current branch to the remote and creates a GitHub Pull Request, auto-filling any detected PR template from commit context and linked Issues. On first run, interviews the user about target branch, draft policy, and template selection, storing config in `docs/agents/pull-requests.md`. Use when the user wants to open a PR, says "create a pull request", "push this branch", "open a PR", "submit for review", or runs /pull-request.
---

# Pull Request

Pushes the current branch and creates a GitHub Pull Request via `gh pr create`, auto-filling any detected PR template from commit context and linked Issues.

## Modes

Check first: does `docs/agents/pull-requests.md` exist?

- **No → Init**: run the interview (see [INTERVIEW.md](INTERVIEW.md)), write config, then proceed to pre-flight.
- **Yes → Proceed**: load config, run pre-flight.

## Pre-flight checks

Run all four in parallel:

- `git remote get-url origin` — remote URL (fails if no remote)
- `git log --oneline -1` — confirms at least one commit exists
- `git status --short` — uncommitted changes
- `git status -sb` — remote tracking state and branch name

Then, in order — abort early if any check fails:

1. **No remote** — if `git remote get-url origin` fails: abort. "No remote named `origin` is configured. Add one with `git remote add origin <url>` then re-run."

2. **No commits** — if `git log` returns empty: abort. "No commits found. Make at least one commit before opening a Pull Request."

3. **Uncommitted changes** — if dirty and the user has not already indicated what to do: ask. Suggest `/commit` if available, otherwise suggest committing manually. Do not proceed until the working tree is clean.

4. **Current branch** — if on the configured target branch and `allow-direct-push` is `false`: abort with guidance. Example: "You're on `main`. Create a feature branch first (`/create-branch`)."

5. **Remote tracking state**:

   - Branch not yet pushed → push in step 1 of the workflow.
   - Branch already pushed, no PR open → skip to PR creation.
   - Branch already pushed, PR already open → report the existing PR URL and stop.

## Workflow

1. **Push branch** (if not yet pushed) — run `git push -u origin <branch>`. Never force-push.

2. **Detect PR template** — in order:

   - Repo-level: check `.github/PULL_REQUEST_TEMPLATE.md`, then `.github/PULL_REQUEST_TEMPLATE/*.md`
   - Org-level: `gh api repos/<org>/.github/contents/.github/PULL_REQUEST_TEMPLATE.md` (and `PULL_REQUEST_TEMPLATE/`)
   - If multiple templates found: check config for the selected template; if none recorded (config pre-dates the template), ask and update config.
   - If no template found anywhere: skip to step 4b.

3. **Build PR title** — infer from commit subjects:

   - Single commit → use its subject line directly.
   - Multiple commits → derive a one-line summary that captures the shared intent.

4. **Build PR body**:

   - **Template found (4a)**: auto-fill each section using commit messages, diff context, and linked Issue. Extract the Issue Number from the branch name (`<type>/<issue>-<slug>`). If the template contains a section for issue references (e.g. "Closes", "Fixes", "Related issues"), inject `Closes #<n>` there. Do not append it outside the template.
   - **No template (4b)**: generate a short prose description of the changes from the commit context. Append `Closes #<n>` on its own line at the end if an Issue Number is present in the branch name.

5. **Present and confirm** — show the proposed title, body, target branch, and draft status. Allow the user to edit any field. Do not call `gh pr create` until the user confirms.

6. **Create PR** — run:

   ```sh
   gh pr create \
     --title "<title>" \
     --body "<body>" \
     --base <target-branch> \
     [--draft]
   ```

   Report the PR URL when done.

## Key rules

- Never force-push.
- Never call `gh pr create` without explicit user confirmation of title and body.
- `gh` CLI is the only interface for GitHub operations. Do not use the REST API directly.
- If `gh` is not authenticated, pause and guide the user through `gh auth login` before continuing.
- `allow-direct-push` applies only to the configured target branch. Any other branch may be pushed freely.
