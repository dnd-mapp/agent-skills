# Output Files

The skill writes or updates the following files after the interview completes.

---

## 1. `docs/agents/issue-tracker.md`

General issue tracker config. Agents load this first; it points to `issue-types.md` for the full type definitions.

**Template:**

```md
# Issue Tracker

Issues are tracked locally as Markdown files.

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

Populate with the values collected in the interview. Adjust the shared fields table and numbering scheme to match what the user configured.

---

## 2. `docs/agents/issue-types.md`

Full per-type definitions. Only loaded by an agent when it needs to work with a specific Issue Type.

**Template:**

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

Repeat a section for each Issue Type. Use the field tables, statuses, and body templates collected during the interview.

---

## 3. `docs/planning/issues/`

Create this directory if it does not already exist. Leave it empty — a separate skill creates individual issue files.

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

- **If absent:** create with the following content:

  ```md
  # Agent configuration

  ## Issue tracker

  This repo uses local issue tracking. For configuration, see [docs/agents/issue-tracker.md](docs/agents/issue-tracker.md).
  ```

- **If present:** add or update the `## Issue tracker` section. Do not touch other sections.
