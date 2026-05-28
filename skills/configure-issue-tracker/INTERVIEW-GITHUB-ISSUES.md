# GitHub Issues Backend Interview

---

## Group GI1 — Issue Type labels

*(Skip if org context — org-level Issue Types are used instead, configured via INTERVIEW-GITHUB.md.)*

For each Issue Type that will be defined in INTERVIEW-SHARED.md, check whether a matching label already exists:

```
gh label list --repo {owner}/{repo}
```

- **Label exists:** confirm it will be used as-is.
- **Label does not exist:** it will be created during provisioning.

No sub-questions needed unless the user wants to customise a label name or colour.

**Default label colour:** none specified (GitHub assigns a random colour).

---

## Group GI2 — Field mapping

For each per-type field that will be defined in INTERVIEW-SHARED.md, confirm its representation in GitHub Issues.

**Labels (prefixed) — will be created if they do not already exist:**

| Field       | Label format        | Example             |
|:------------|:--------------------|:--------------------|
| `priority`  | `priority:<value>`  | `priority:P0`       |
| `severity`  | `severity:<value>`  | `severity:S1`       |
| `iteration` | `iteration:<value>` | `iteration:Q1-2026` |

Check existing labels via `gh label list` and note which will be created during provisioning.

**Inlined in the Issue body:**

| Field              | Inline format                   |
|:-------------------|:--------------------------------|
| `estimation`       | `**Estimate:** <value>`         |
| `parent`           | `Parent #<n>`                   |
| `target-iteration` | `**Target iteration:** <value>` |

Ask: does this mapping work, or do you want to change any field representation?

---

## Group GI3 — Status sub-states

GitHub Issues use open/closed natively. The terminal statuses (`done` → closed, `backlog` → open) are covered. The in-between statuses from INTERVIEW-SHARED.md will be created as labels.

Check existing labels for conflicts before adding to the provisioning list.

**Default:** create labels for `ready`, `in-progress`, `in-review`.

Ask: are there any statuses you do not want as labels?
