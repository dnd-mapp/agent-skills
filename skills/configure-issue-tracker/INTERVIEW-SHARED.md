# Shared Interview Questions

These questions apply to all Tracker Backends. Run after the backend-specific interview file.

---

## Group S1 — Foundation

### Issue Types

What Issue Types exist for this repo?

**Default:** Epic, Story, Task, Bug

### Hierarchy

*(Only ask if more than one Issue Type was defined.)*

Which types can contain which?

**Default:** Epic → Story → Task. Bug is standalone.

---

## Group S2 — Per-type config

Repeat for each Issue Type. Show defaults per type; only drill in when the user overrides.

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

**Default:** enabled for Epics, Stories, and Bugs — format: Quarters (e.g. `Q1 2026`, `Q2 2026`)

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
