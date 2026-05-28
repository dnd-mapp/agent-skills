# Local Backend Interview

---

## Group L1 — Per-type fields

Repeat for each Issue Type. Show defaults; only drill in when the user overrides.

### Fields

What frontmatter fields does this type have? For each field: is it required or optional? What format or allowed values does it accept?

**Default fields per type** (in addition to shared fields — see Group L2):

| Issue Type | Additional fields                                                                                                                     |
|:-----------|:--------------------------------------------------------------------------------------------------------------------------------------|
| Epic       | `target-iteration` (optional, string)                                                                                                 |
| Story      | `estimation` (optional, story points: 1 2 3 5 8 13), `iteration` (optional, string), `parent` (optional, Issue Number of parent Epic) |
| Task       | `parent` (optional, Issue Number of parent Story)                                                                                     |
| Bug        | `severity` (required, enum: S0 \| S1 \| S2 \| S3), `iteration` (optional, string)                                                     |

---

## Group L2 — Shared fields

Fields that appear on **all** Issue Types regardless of per-type config.

**Default shared fields:**

| Field     | Required | Format                   |
|:----------|:---------|:-------------------------|
| `status`  | required | enum (per-type statuses) |
| `created` | required | ISO date (YYYY-MM-DD)    |

Ask: do you want to add any more shared fields?

---

## Group L3 — Global config

### Storage path

Where are Issue files stored?

**Default:** `docs/planning/issues/`

### Numbering scheme

How are Issue Numbers formatted?

| Scheme             | Example  | Notes                                                     |
|:-------------------|:---------|:----------------------------------------------------------|
| Global sequential  | `#42`    | Default. Simple, clean branch names.                      |
| Project identifier | `DND-42` | Global sequential with a repo-level key. Ask for the key. |

**Default:** global sequential (`#42`)

If project identifier is chosen: ask for the project key (e.g. `DND`, `PROJ`).

### File naming

Does the Issue Type appear in the filename?

**Default:** `<number>-<slug>.md` — type lives only in frontmatter.

Alternative: `<number>-<type>-<slug>.md` (e.g. `0003-story-add-oauth-login.md`)

### Linking conventions

How do Issues reference each other in body text?

**Default:** `Parent #<n>`, `Closes #<n>`, `Refs #<n>`, `Blocks #<n>`

*(Adjust to match the configured numbering scheme — e.g. `Part of DND-3` if a project identifier is used.)*

### Archive policy

When an issue is closed, does it stay in place or move to a subdirectory?

**Default:** stay in place (no move)

Alternative: move to `docs/planning/issues/archive/`
