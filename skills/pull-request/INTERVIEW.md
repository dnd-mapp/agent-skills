# Interview

Runs on first invocation when `docs/agents/pull-requests.md` does not exist. Collect answers, present a review, then write config (see [OUTPUTS.md](OUTPUTS.md)).

---

## Question 1 — Default target branch

Auto-detect with `git branch --list main`. Suggest `main` if it exists, `master` otherwise. Present the detected default and ask the user to confirm or change it.

---

## Question 2 — Direct push to target branch

Ask: "Should the skill allow pushing directly to `<target-branch>` without a PR?"

Default: **not allowed** — block and redirect to `/create-branch`.

---

## Question 3 — Draft PRs

Ask: "Should PRs be created as drafts by default?"

Default: **no**. Can be overridden per invocation at runtime ("open this as a draft").

---

## Question 4 — PR template

Detect templates before asking:

1. Check `.github/PULL_REQUEST_TEMPLATE.md` and `.github/PULL_REQUEST_TEMPLATE/*.md` in the current repo.
2. Fetch org-level equivalents: `gh api repos/<org>/.github/contents/.github/PULL_REQUEST_TEMPLATE.md` and `.github/PULL_REQUEST_TEMPLATE/`. Extract the org from `git remote get-url origin`.

Then:

| Templates found | Action                                                                                    |
|:----------------|:------------------------------------------------------------------------------------------|
| None            | Skip question. Record `template: none`.                                                   |
| Exactly one     | Use automatically. Record path and level (repo or org). Tell the user which was detected. |
| Multiple        | List all options and ask which to use as the default. Record the selected path and level. |

---

## Review & Approve

Before writing any files, present a summary:

- Target branch
- Direct push policy
- Draft default
- Selected PR template (or none)
- Files that will be written (`docs/agents/pull-requests.md`, `AGENTS.md`)

Ask for explicit approval. If the user wants to change anything, return to the relevant question. Only proceed after approval is given.
