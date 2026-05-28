# GitHub Common Interview

Applies to both `github-issues` and `github-issues-projects` backends. Run before the backend-specific interview file.

---

## Group G0 — GitHub Setup

### Repo

Auto-detect the GitHub repo from `git remote get-url origin`. Confirm with the user.

If the remote is not a GitHub URL, ask for the repo in `owner/repo` format.

### Auth check

Run `gh auth status` and verify all of the following:

- `gh` CLI is installed
- The user is authenticated
- Required scopes are present:
  - `repo` — always required (creating labels, reading repo metadata)
  - `project` — required for `github-issues-projects` only
  - `admin:org` — required only if org context is detected (org-level Issue Types)

If any check fails: **pause the interview immediately**. Explain exactly what is missing and provide the `gh auth login --scopes "..."` command the user needs to run. Do not proceed until the user confirms the issue is resolved.

### Org detection

Call `gh api /repos/{owner}/{repo}` to check if the owner is a GitHub organization.

- **Org detected:** "This repo belongs to org `{org}`. Issue Types will use GitHub's org-level issue types feature."
  - Attempt `gh api /orgs/{org}/issue-types` to verify org admin access.
  - If access is denied: surface a hard error — explain that org admin scope is required for org-level Issue Types, provide the scope needed, and pause. Do not silently fall back to a different mechanism.
- **Personal repo detected:** "This is a personal repo. Issue Types will use labels (or a Projects `Type` field if a Project is configured)."
