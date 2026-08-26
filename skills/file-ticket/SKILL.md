---
name: file-ticket
description: File a ticket on the repo's issue tracker by drafting a title and body from the current conversation, filling the repo's issue template if it has one, checking for near-duplicates, and creating it after your review. Use when the user wants to file a ticket, or when another skill needs one filed.
---

# File Ticket

File a new ticket: derive a title and body from the current conversation, fill in the target repo's issue template if it has one, surface near-duplicate open issues, get your review, then create it and hand back its number and URL.

This skill's flow is tracker-agnostic. Tracker-specific mechanics (the concrete implementation of each Operation below) live in `skills/file-ticket/operations/<tracker>.md`, one file per supported tracker, selected by this repo's configured tracker. V1 ships [operations/github.md](operations/github.md) only.

## 1. Load or bootstrap the repo config

Read [docs/agents/file-ticket.md](../../docs/agents/file-ticket.md) for this repo's target repo, default labels, and tracker.

If that file doesn't exist yet, offer to create it:

- **Target repo**: never ask. Resolve silently via the `resolve-target-repo()` Operation (no override, no default) and record the resolved `owner/repo`.
- **Default labels**: optional. Call `list-labels(repo)` and present the repo's real labels for the user to pick defaults from; accept freeform text too, for a label that doesn't exist in the repo yet. An empty selection records the field as empty.
- **Tracker**: always ask, via a closed-choice prompt: "Which tracker does this repo use? Currently supported: `github`." Record whatever is answered, even if unsupported.

Present the drafted Target repo, Default labels, and Tracker together for confirmation before writing anything. If changes are requested, revise and present the full draft again. Once confirmed, write the file with just these three fields and ask whether to commit it on the current branch, folded into whatever this session is already about, or on a separate branch as its own PR. Either is legitimate, don't assume.

Whether just bootstrapped or loaded from an existing file, re-validate the loaded `Tracker` value against the trackers this build ships an operations file for (`skills/file-ticket/operations/<tracker>.md` exists; `github` only, today). If it isn't one of them, surface a loud warning (filing will fail) and stop. Do this on every load, not just at bootstrap, so support landing later clears the warning automatically and a config that regresses catches it again.

## 2. Resolve the target repo

Optional per-invocation override (a repo named explicitly in conversation). Resolve via the `resolve-target-repo(override?, default)` Operation, `default` being step 1's config value. This validates the target immediately (`gh repo view`) rather than letting a typo surface confusingly later inside ticket creation.

## 3. Derive the title and body

Draft a title and body from the current conversation context (the bug, request, or task being discussed), the same "read the actual content, don't mechanically parse" approach `/branch` and `/pr` take with a diff. The title should be concise and specific enough to distinguish this ticket from a similar one. The body should stand alone: someone reading only the ticket, without this conversation, needs enough context to act on it.

## 4. Fetch and apply an issue template

Call `fetch-template(repo)`.

- **Zero Candidates**: no Template Candidate exists; draft the body freeform from step 3.
- **One Candidate**: read its raw content and draft the body to fit its sections (Markdown chooser), field labels as headings (YAML form), or existing structure (legacy single-file template, no front matter `name`/`about`), rather than freeform.
- **Multiple Candidates**: present each Candidate's `name` and `about` to the user, plus a "no Template Candidate" option, and ask which to use, matching this skill's own draft-and-approve default rather than adding a second, unreviewed guess. This is the only structured signal GitHub itself exposes for choosing between them.

## 5. Search for duplicates

Call `search-duplicates(repo, <drafted title>)`.

- **`ok: false`**: surface a loud warning and continue without dedup, the same warn-and-continue pattern `review-comments` step 3 uses for its own failed lookup. Don't treat this as "confirmed zero duplicates."
- **`ok: true`**: hold the returned candidates for the draft-and-approve step below.

## 6. Resolve labels

Merge step 1's default labels with any labels requested at invocation into one fully-resolved list. `create-ticket` does no merging of its own.

## 7. Run writing-style

Run the `writing-style` skill over the drafted title and body before presenting them in the next step.

## 8. Draft, then review before touching the tracker

Present the target repo, title, body, and labels. If step 5 found candidates, show a short "Possible duplicates" list (number, title, url) above the draft, folded into this same confirmation rather than a separate gate.

Wait for explicit approval before creating anything. If duplicates were shown, the user's choice is binary: file anyway (proceed unchanged), or stop (abort without creating). If changes are requested, revise and present the full draft again rather than applying part of it.

## 9. Apply

Call `create-ticket(repo, title, body, labels)` → `{number, url}`.

Show the resulting ticket URL, and return the number and URL as this skill's result to whatever invoked it.
