---
name: create-issues
description: Extracts action items and gaps from the current conversation and codebase, then creates Issues in the configured Tracker Backend. Use when the user wants to create, log, or capture issues, says "create issues", "create an issue for X", "track this as an issue", "capture issues from this conversation", or runs /create-issues.
---

# Create Issues

Extracts candidate Issues from the conversation and codebase context, proposes them for review, then creates them in the configured Tracker Backend.

## Pre-flight

1. **Check for issue tracker config** — read `docs/agents/issue-tracker.md`. If absent, stop immediately:

   > No issue tracker configured for this repo. Run `/configure-issue-tracker` to set one up.

2. **Load Issue Types** — read `docs/agents/issue-types.md` to know the available Issue Types, their required and optional fields, statuses, and body templates.

## Workflow

### 1. Collect context

Run all of the following in parallel:

- `git diff HEAD` (tracked modifications)
- `git diff --cached` (already staged)
- `git status --short` (untracked files)
- `git log @{u}..HEAD --format="%s%n%b"` (unpushed commits — treat failure as empty)
- Read source files referenced by the conversation (targeted exploration — do not read files not mentioned or implied by the conversation)
- Grep for patterns implied by the discussion if the conversation references a specific area of the codebase

### 2. Extract candidates

Scan the conversation and collected context for two kinds of candidates:

- **Explicitly flagged**: Items the user directly called out as work to track ("we should track that", "create an issue for X", "this needs a ticket").
- **Inferred**: Action items, gaps, deferred decisions, or unresolved ambiguities surfaced during the conversation that represent discrete units of tracked work.

When the user names a specific item ("create an issue for X"), use the conversation and codebase context to determine whether it warrants one Issue or several — complexity dictates the count, not the phrasing.

For each candidate, determine:

- **Title**: A concise, specific phrase.
- **Issue Type**: Infer from context using the loaded Issue Type definitions. A broad goal → Epic; a discrete deliverable → Story; a specific action → Task; a defect → Bug. When ambiguous, default to Task.
- **Required fields**: `status: backlog`, `created: <today's date>`.
- **Optional fields**: Populate all optional fields defined in `issue-types.md` for this Issue Type. For each field: use the value from the conversation / codebase context if inferable; otherwise use the field's defined default if one exists; otherwise leave blank. Note every blank field explicitly in the review gate.
- **Body**: Populate the Issue Type's body template with content drawn from the conversation and codebase. Leave sections blank where context is insufficient — do not invent content.

**Full hierarchy decomposition:** When the configured Issue Types include Tasks, every Story that is extracted or created must be accompanied by at least one Task. For each Story, extract the concrete Tasks needed to implement it — a Task is a specific, actionable step (an hour to a day of work), not a sub-story. If a Story has no natural breakdown into discrete steps, a single Task is acceptable. Present the complete Epic → Story → Task tree at the review gate.

### 3. Review gate

Present all candidates grouped by source before writing anything. Show the full Epic → Story → Task tree (indented) when a hierarchy is present. For each Issue, list all optional fields defined for its Issue Type — populated, defaulted, or explicitly noted as blank:

```md
## Explicitly flagged

1. [Task] Fix expired token handling in auth middleware
   status: backlog | created: 2026-05-28 | priority: P2
   estimation: (blank — no complexity signals)
   Body: ## Description\n\nThe auth middleware does not...

2. ...

## Inferred from conversation

3. [Epic] Auth system overhaul
   status: backlog | created: 2026-05-28 | priority: P1
   Body: ## Goal\n\n...

   4. [Story] Migrate session storage to Redis
      status: backlog | created: 2026-05-28 | priority: P2 | estimation: 5
      Body: ## Goal\n\n...

      5. [Task] Add Redis client configuration
         status: backlog | created: 2026-05-28 | estimation: 2
         Body: ## Description\n\n...
```

For any blank field, state it explicitly: `fieldName: (blank — <reason>)`. Do not silently omit optional fields.

Allow the user to:

- Edit any field or body before approving
- Remove items from the list
- Add items not captured by the extraction

Do not proceed until the user explicitly approves.

### 4. Execute

Create Issues one by one in the order presented (parents before children). On first failure, stop immediately and report:

- Which Issues were created successfully (with their numbers or URLs)
- Which Issue failed and why
- Which Issues were not attempted

Do not attempt further creation after a failure.

**Body construction (all backends):** When building body strings in bash, always produce real newlines — not literal `\n` characters. Use `printf` or `$'...'` syntax:

```bash
# Correct
body="$(printf '## Description\n\nSome text')"
# or
body=$'## Description\n\nSome text'
```

Never pass a double-quoted string containing `\n` directly to `gh` or `jq`.

---

**Local backend:**

1. Scan `docs/planning/issues/` filenames to find the highest existing Issue Number.
2. Increment by one for each new Issue (assign sequentially within this run).
3. Write `docs/planning/issues/<number>-<slug>.md` with frontmatter and body.
   - Store parent references in frontmatter: `parent: <number>`
   - Store blocking relations in frontmatter: `blocks: [<number>, ...]` and `blocked-by: [<number>, ...]`
4. Do not stage or commit the files.

---

**`github-issues` backend:**

- Run `gh issue create --title "<title>" --body "<body>" --label "<type-label>" [--label "<field-labels>"]`
- Apply field labels per the mappings in `docs/agents/issue-types.md` (priority, severity, iteration labels as configured).
- Body fields not represented as labels (parent references, estimation, target iteration) are inlined in the body per the config.
- Set blocking relations after creation using the GitHub dependencies API: `gh api repos/{owner}/{repo}/issues/{issue_number}/dependencies` or the `addBlockedBy` GraphQL mutation per the node IDs.

---

**`github-issues-projects` backend:**

- Run `gh issue create` as above to create the issue. Capture the returned URL.
- Add the created issue to the configured Project: `gh project item-add <project-number> --owner <owner> --url "$url" > /dev/null`
- Set Project custom fields (status, priority, etc.) using the node IDs from `docs/agents/issue-types.md`.
- Wire up parent–child relationships using the `addSubIssue` GraphQL mutation. Do **not** include `Parent #<n>` in the issue body — the relationship is set natively.
- Set blocking relations after creation using the `addBlockedBy` GraphQL mutation with the node IDs of both issues.

### 5. Confirm

After all Issues are created, output a summary:

```
Created 3 issues:

- #42 [Task] Fix expired token handling in auth middleware
- #43 [Task] Add rate limiting to login endpoint
- #44 [Story] Migrate session storage to Redis
```

For GitHub backends, include the issue URL next to each number.

## Defaults

| Concern            | Default                                                                             | Override                                |
|:-------------------|:------------------------------------------------------------------------------------|:----------------------------------------|
| Initial status     | `backlog`                                                                           | Inferable from conversation             |
| Issue Type         | `Task` when ambiguous                                                               | Inferable from context                  |
| Optional fields    | Field's defined default (from `issue-types.md`); blank if none — flagged explicitly | Inferable from conversation or codebase |
| Task decomposition | At least one Task per Story when Tasks are a configured Issue Type                  | —                                       |
| Extraction scope   | Full conversation + working tree + referenced files                                 | User-scoped request narrows naturally   |
| Git commit (local) | Never                                                                               | —                                       |
| Push to remote     | Never                                                                               | —                                       |
