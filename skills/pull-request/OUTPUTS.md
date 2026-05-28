# Output Files

Written after the interview is approved.

---

## 1. `docs/agents/pull-requests.md`

```md
# Pull Requests

## Target branch

main

## Direct push to target branch

not allowed  ← or: allowed

## Draft by default

false  ← or: true

## PR template

.github/PULL_REQUEST_TEMPLATE.md (repo-level)  ← or: org-level path / none
```

Populate all values from the interview.

---

## 2. `AGENTS.md`

- **If absent**: create with:

  ```md
  # Agent configuration

  ## Pull requests

  This repo uses GitHub for pull requests. For configuration, see [docs/agents/pull-requests.md](docs/agents/pull-requests.md).
  ```

- **If present**: add or update the `## Pull requests` section. Do not touch other sections.
