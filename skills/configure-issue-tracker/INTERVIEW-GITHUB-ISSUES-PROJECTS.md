# GitHub Issues + Projects Backend Interview

---

## Group GP1 — Project selection

List available Projects for this repo:

```sh
gh api graphql -f query='
{
  repository(owner: "{owner}", name: "{repo}") {
    projectsV2(first: 20) {
      nodes { id title number }
    }
  }
}'
```

- **Projects exist:** show the list and ask which to use.
- **No Projects exist:** offer to create one. Ask for the Project title. The Project will be created via `createProjectV2` during provisioning. If the `project` scope is missing, pause and guide the user — do not proceed.

Record both the human-readable Project number (`#12`) and the node ID (`PVT_...`) returned by the API.

---

## Group GP2 — Issue Type field

*(Skip if org context — org-level Issue Types are used instead. The Issue Type is set on the backing GitHub Issue and is visible in the Project without a separate field.)*

For personal repos, the Issue Type will be stored as a `Type` single-select field on the Project.

Check if a `Type` field already exists on the selected Project:

```sh
gh api graphql -f query='
{
  node(id: "{projectId}") {
    ... on ProjectV2 {
      fields(first: 50) {
        nodes {
          ... on ProjectV2SingleSelectField { id name options { id name } }
        }
      }
    }
  }
}'
```

- **Field does not exist:** it will be created during provisioning with the Issue Types from INTERVIEW-SHARED.md as options. Record the field name (`Type`).
- **Field exists:** in update mode, options on an existing single-select field cannot be changed via the GitHub API — the only alternative is to delete and recreate the field, which destroys all existing field values on Project items. Do not do this. Show the current options. If the user wants to add or remove options, provide guidance on doing so manually in the GitHub UI or via `gh`, and note the divergence in config.

---

## Group GP3 — Per-type field mapping

For each per-type field that will be defined in INTERVIEW-SHARED.md, confirm the Projects custom field that will be created:

| Field              | Projects field type | Notes                                       |
|:-------------------|:--------------------|:--------------------------------------------|
| `priority`         | Single-select       | Options from the configured priority levels |
| `severity`         | Single-select       | Options from the configured severity levels |
| `estimation`       | Number              | Story points                                |
| `iteration`        | Iteration           | Native Projects iteration field type        |
| `target-iteration` | Text                | Epic-specific; free-text string             |
| `parent`           | Text                | e.g. `Parent #12`                           |

Check which fields already exist on the Project (use the query from Group GP2). For each:

- **Does not exist:** add to provisioning list.
- **Exists with matching options:** confirm it will be used as-is. Record the node ID.
- **Exists with mismatched options:** do not modify — changing options requires deleting and recreating the field, which destroys all existing values. Show current state, give manual guidance, note the divergence.

Ask: does this mapping work, or do you want to change any field?

---

## Group GP4 — Status field

The lifecycle statuses from INTERVIEW-SHARED.md will be created as options on a `Status` single-select field on the Project.

Check if a `Status` field already exists (use the query from Group GP2).

- **Does not exist:** it will be created during provisioning with all configured status values as options. 
- **Exists:** do not modify — changing options requires deleting and recreating the field, which destroys all existing values. Show current options. If the configured statuses differ, give manual guidance on reconciling them.
