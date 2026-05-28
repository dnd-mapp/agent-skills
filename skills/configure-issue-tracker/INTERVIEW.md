# Interview Structure

The interview is **adaptive grouped sequential**: questions are grouped by topic, and sub-questions are only asked when the user wants to override a default. At the start of each group, surface all defaults and ask "does this work, or do you want to change anything?"

---

## Group 1 — Foundation

### Issue Types

What Issue Types exist for this repo?

**Default:** Epic, Story, Task, Bug

### Hierarchy

*(Only ask if more than one Issue Type was defined.)*

Which types can contain which?

**Default:** Epic → Story → Task. Bug is standalone.

---

## Group 2 — Per-type config

Repeat for each Issue Type. Show defaults per type; only drill in when the user overrides.

### Fields

What frontmatter fields does this type have? For each field: is it required or optional? What format or allowed values does it accept?

**Default fields per type** (in addition to shared fields — see Group 3):

| Issue Type | Additional fields                                                                                                                     |
|------------|---------------------------------------------------------------------------------------------------------------------------------------|
| Epic       | `target-iteration` (optional, string)                                                                                                 |
| Story      | `estimation` (optional, story points: 1 2 3 5 8 13), `iteration` (optional, string), `parent` (optional, Issue Number of parent Epic) |
| Task       | `parent` (optional, Issue Number of parent Story)                                                                                     |
| Bug        | `severity` (required, enum: S0 \| S1 \| S2 \| S3), `iteration` (optional, string)                                                     |

### Statuses

What lifecycle statuses apply to this type?

**Default:** `backlog`, `ready`, `in-progress`, `in-review`, `done`

### Priority

Does this type use priority? If so, what levels?

**Default:** enabled for Epics, Stories, and Bugs — levels: `P0`, `P1`, `P2`, `P3`

### Severity

Does this type use severity? If so, what levels?

**Default:** enabled for Bug only — levels: `S0`, `S1`, `S2`, `S3`

### Estimation

Does this type use estimation? If so, what format?

**Default:** enabled for Story — format: story points (1, 2, 3, 5, 8, 13)

### Iteration

Does this type use iteration (sprint/milestone)?

**Default:** enabled for Epics — format: Quarters (e.g. `Q1 2026`, `Q2 2026`)

### Body template

What is the default Markdown structure below the `# Title` for this type?

**Defaults:**

- **Epic**

  ```md
  ## Goal

  ## Scope

  ## Out of scope
  ```

- **Story**

  ```md
  ## User Story
  
  As a [persona], I want [goal], so that [reason].

  ## Acceptance criteria
  
  - [ ]
  - [ ]
  ```

- **Task**

  ```md
  ## Description
  ```

- **Bug**
  ```md
  ## Steps to reproduce

  ## Expected

  ## Actual

  ## Environment
  ```

---

## Group 3 — Shared fields

Fields that appear on **all** Issue Types regardless of per-type config.

**Default shared fields:**

| Field       | Required  | Format                      |
|:------------|:----------|:----------------------------|
| `status`    | required  | enum (per-type statuses)    |
| `created`   | required  | ISO date (YYYY-MM-DD)       |

Ask: do you want to add any more shared fields?

---

## Group 4 — Global config

### Storage path

Where are Issue files stored?

**Default:** `docs/planning/issues/`

### Numbering scheme

How are Issue Numbers formatted? Options:

| Scheme             | Example             | Notes                                                     |
|--------------------|---------------------|-----------------------------------------------------------|
| Global sequential  | `#42`               | Default. Simple, clean branch names.                      |
| Project identifier | `DND-42`            | Global sequential with a repo-level key. Ask for the key. |

**Default:** global sequential (`#42`)

If project identifier is chosen: ask for the project key (e.g. `DND`, `PROJ`).

### File naming

Does the Issue Type appear in the filename?

**Default:** `<number>-<slug>.md` — type lives only in frontmatter.

Alternative: `<number>-<type>-<slug>.md` (e.g. `0003-story-add-oauth-login.md`)

### Linking conventions

How do Issues reference each other in body text?

**Default:** `Parent #<n>`, `Closes #<n>`, `Refs #<n>`, `Blocks #<n>`

*(Adjust to match the configured numbering scheme — e.g. `Part of STORY-3` if per-type prefixes are used.)*

### Archive policy

When an issue is closed, does it stay in place or move to a subdirectory?

**Default:** stay in place (no move)

Alternative: move to `docs/planning/issues/archive/`
