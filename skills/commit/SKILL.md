---
name: commit
description: Commit the working tree, grouped into separate commits by intent with Conventional Commits messages, reviewed with you before anything is applied.
disable-model-invocation: true
---

# Commit

Turn the current working tree into one or more commits: group changes by intent, draft a [Conventional Commits](https://www.conventionalcommits.org/) message per group, get your review, then apply.

## 1. Inspect the full tree

Re-derive the picture from scratch every time: `git status`, `git diff`, and `git diff --staged` together. Never treat whatever happens to already be staged as correct; re-plan the grouping from the full tree regardless of the current index.

A freshly initialized repo has no commits yet (an unborn branch): `git log` fails on it instead of returning empty. Check for this up front rather than letting a downstream `git log` call error out.

## 2. Group by intent

Each group becomes exactly one commit. A group is everything that serves one purpose:

- Don't split one logical change across commits just because it touches several files.
- Don't merge unrelated purposes into one commit just because they touch the same file: split at the hunk level (`git add -p`, or write and apply a partial patch) when a single file mixes two intents.
- If the whole tree really is one intent, one commit is the correct output. Grouping doesn't mean forcing a split that isn't there.
- Where changes have a dependency order (a refactor a following feature builds on), commit them in that order.

Check `git log` for this repo's own convention around the `type(scope):` scope, and match it unless a scope clearly earns its place. If there's no history yet to learn from, default to no scope. For a breaking change, mark it with `!` after the type (and/or a `BREAKING CHANGE:` footer).

## 3. Subject

The subject is the free text after `type(scope):` on the header line.

Write it lowercase, with no trailing period. `commitlint` already enforces both; state them here so a draft gets them right the first time instead of finding out from the hook.

Use the imperative mood: `add retry logic`, not `added retry logic` or `adds retry logic`.

Keep it to about 50 characters. `commitlint`'s enforced ceiling is 100, but a subject that long already reads poorly once truncated in `git log --oneline` or a narrow terminal.

Be specific about what changed, not just mechanically correct: `fix bug` or `update code` passes every rule above and still tells a future reader nothing.

## 4. Body

Add a body when the subject line alone doesn't make the *why* self-evident: what problem this solves, what changed from before, why this approach over an alternative. Skip it when the subject already says everything a future reader needs.

Explain *why*, not *how*: the diff already shows how. Write it as prose, not an imperative-mood continuation of the subject; the imperative-mood rule applies to the subject line only. Wrap at 72 characters, separated from the subject by one blank line.

## 5. Footer

Add a footer when one of these applies to the commit:

- **`BREAKING CHANGE: <description>`**: for a breaking change (see step 2).
- **`Refs: #<issue>`**: this commit relates to an issue/ticket, without closing it.
- **`Closes: #<issue>`**: this commit resolves an issue/ticket. Use `Closes:` even though GitHub only registers a closing keyword from a PR description, not a commit message; it still tells a human reading `git log` what this commit was for. See [ADR 0001](../../docs/adr/0001-keep-issue-closing-keywords-in-commit-footers.md).
- **`Link: <url>`**: external context worth preserving (a discussion, a design doc, a reference) that isn't an issue reference.
- **`DEPRECATED: <what, and the replacement>`**: this commit deprecates a skill, agent, or other behavior.
- **`Co-authored-by: Name <email>`**: the commit has more than one author.

To find an issue/ticket number: check the current branch name for a plausible reference (e.g. a leading issue number) and, if found, propose it as part of the draft in step 6 rather than asserting it silently; the user confirms or corrects it there. Don't invent a reference that isn't in the branch name or given by the user.

In a multi-commit split, only add a ticket footer to the commit(s) whose intent actually matches that ticket, not every commit in the group.

## 6. Draft, then review before touching git state

Present the full plan: each group's files (or hunks) alongside its exact drafted commit message. Wait for explicit approval before running any `git add` or `git commit`. If changes are requested, revise the plan and present it again rather than applying part of it.

## 7. Apply

Once approved, work through the groups in order: stage exactly that group's files or hunks, commit with the reviewed message, then move to the next group. Finish by showing the resulting `git log` so the outcome is visible.

If the tree has no changes, say so and stop. There's nothing to group.
