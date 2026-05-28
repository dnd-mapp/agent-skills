# Output Files

The skill writes or updates the following files after the review gate is approved.

---

## 1. `docs/agents/issue-tracker.md`

General issue tracker config. Agents load this first; it points to `issue-types.md` for the full type definitions.

### Template: `local`

```md
# Issue Tracker

## Tracker Backend

local

## Storage

- **Path:** `docs/planning/issues/`
- **File naming:** `<number>-<slug>.md`
- **Numbering scheme:** global sequential (`#N`)
- **Archive policy:** closed issues stay in place

## Linking conventions

- `Parent #<n>` — parent reference
- `Closes #<n>` — resolution reference
- `Refs #<n>` — related reference

## Shared fields

All Issue Types include these frontmatter fields:

| Field     | Required | Format                |
|:----------|:---------|:----------------------|
| `status`  | required | see per-type statuses |
| `created` | required | ISO date (YYYY-MM-DD) |

## Issue Types

For full Issue Type definitions (fields, statuses, body templates), see [issue-types.md](issue-types.md).
```

### Template: `github-issues`

```md
# Issue Tracker

## Tracker Backend

github-issues

## GitHub

- **Repo:** `owner/repo`
- **Org:** `acme` ← omit if personal repo

## Issue Types

Configured as GitHub org-level issue types.  ← or: "GitHub labels" if personal repo. For full definitions, see [issue-types.md](issue-types.md).

## Field representation

- **Priority:** GitHub label, prefixed (`priority:P0`)
- **Severity:** GitHub label, prefixed (`severity:S1`)
- **Iteration:** GitHub label, prefixed (`iteration:Q1-2026`)
- **Estimation:** Inlined in Issue body (`**Estimate:** 5`)
- **Parent:** Inlined in Issue body (`Parent #12`)
- **Target iteration:** Inlined in Issue body (`**Target iteration:** Q2 2026`)

## Linking conventions

- `Parent #<n>` — parent reference
- `Closes #<n>` — resolution reference
- `Refs #<n>` — related reference
```

### Template: `github-issues-projects`

```md
# Issue Tracker

## Tracker Backend

github-issues-projects

## GitHub

- **Repo:** `owner/repo`
- **Project:** `#12` — "My Project" (`PVT_...`) ← include node ID
- **Org:** `acme` ← omit if personal repo

## Issue Types

Configured as GitHub org-level issue types.  ← or: "Projects `Type` single-select field (`PVTSSF_...`)" if personal repo. For full definitions, see [issue-types.md](issue-types.md).

## Linking conventions

- `Parent #<n>` — parent reference
- `Closes #<n>` — resolution reference
- `Refs #<n>` — related reference
```

Populate all values from the interview. Node IDs are recorded alongside human-readable identifiers wherever they appear.

---

## 2. `docs/agents/issue-types.md`

Full per-type definitions. Only loaded by an agent when it needs to work with a specific Issue Type. For GitHub backends, each type section includes field mappings with node IDs for any GitHub-provisioned fields.

### Template: `local`

```md
# Issue Types

## Epic

**Hierarchy:** can contain Stories

### Fields

| Field              | Required | Format                                               |
|:-------------------|:---------|:-----------------------------------------------------|
| `type`             | required | `Epic`                                               |
| `status`           | required | backlog \| ready \| in-progress \| in-review \| done |
| `created`          | required | ISO date                                             |
| `priority`         | optional | P0 \| P1 \| P2 \| P3                                 |
| `target-iteration` | optional | string                                               |

### Body template

## Goal

## Scope

## Out of scope

---

## Story

...
```

Repeat a section for each Issue Type.

### Template: `github-issues`

```md
# Issue Types

## Epic

**Hierarchy:** can contain Stories

### Issue Type label

`Epic`  ← or: org-level issue type name

### Fields

| Field              | Representation                            | Values / format      |
|:-------------------|:------------------------------------------|:---------------------|
| `priority`         | Label — `priority:<value>`                | P0 \| P1 \| P2 \| P3 |
| `target-iteration` | Inlined in body — `**Target iteration:**` | string               |

### Statuses

| Status        | GitHub representation     |
|:--------------|:--------------------------|
| `backlog`     | Open (no sub-state label) |
| `ready`       | Label — `ready`           |
| `in-progress` | Label — `in-progress`     |
| `in-review`   | Label — `in-review`       |
| `done`        | Closed                    |

### Body template

## Goal

## Scope

## Out of scope

---

## Story

...
```

### Template: `github-issues-projects`

```md
# Issue Types

## Epic

**Hierarchy:** can contain Stories

### Issue Type

Org-level issue type: `Epic`  ← or: Projects `Type` field option `Epic` (field node ID: `PVTSSF_...`, option ID: `...`)

### Fields

| Field              | Projects field             | Node ID      | Type          | Values / format      |
|:-------------------|:---------------------------|:-------------|:--------------|:---------------------|
| `priority`         | `Priority` (single-select) | `PVTSSF_...` | Single-select | P0 \| P1 \| P2 \| P3 |
| `target-iteration` | `Target iteration` (text)  | `PVTF_...`   | Text          | string               |

### Statuses

`Status` field (single-select, node ID: `PVTSSF_...`):

| Status        | Option ID |
|:--------------|:----------|
| `backlog`     | `...`     |
| `ready`       | `...`     |
| `in-progress` | `...`     |
| `in-review`   | `...`     |
| `done`        | `...`     |

### Body template

## Goal

## Scope

## Out of scope

---

## Story

...
```

Repeat a section for each Issue Type. Record all node IDs returned by the GitHub API during provisioning.

---

## 3. `docs/planning/issues/`

**Local backend only.** Create this directory if it does not already exist. Leave it empty — a separate skill creates individual issue files.

Do **not** create this directory for GitHub backends.

---

## 4. `CLAUDE.md`

- **If absent:** create with the following content:

  ```md
  # Claude instructions

  For agent instructions and repo-specific configuration, see [AGENTS.md](AGENTS.md).
  ```

- **If present:** append the following line if it is not already there:

  ```md
  For agent instructions and repo-specific configuration, see [AGENTS.md](AGENTS.md).
  ```

---

## 5. `AGENTS.md`

- **If absent:** create with the following content — adapt the description to the configured backend:

  ```md
  # Agent configuration

  ## Issue tracker

  This repo uses local issue tracking. For configuration, see [docs/agents/issue-tracker.md](docs/agents/issue-tracker.md).
  ```

  For `github-issues`:

  ```md
  This repo uses GitHub Issues for issue tracking. For configuration, see [docs/agents/issue-tracker.md](docs/agents/issue-tracker.md).
  ```

  For `github-issues-projects`:

  ```md
  This repo uses GitHub Issues and GitHub Project #12 ("My Project") for issue tracking. For configuration, see [docs/agents/issue-tracker.md](docs/agents/issue-tracker.md).
  ```

- **If present:** add or update the `## Issue tracker` section. Do not touch other sections.
