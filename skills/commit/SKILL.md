---
name: commit
description: Commit the working tree, grouped into separate commits by intent with Conventional Commits messages, reviewed with you before anything is applied.
disable-model-invocation: true
---

# Commit

Turn the current working tree into one or more commits: group changes by intent, draft a [Conventional Commits](https://www.conventionalcommits.org/) message per group, get your review, then apply.

## 1. Inspect the full tree

Re-derive the picture from scratch every time: `git status`, `git diff`, and `git diff --staged` together. Never treat whatever happens to already be staged as correct; re-plan the grouping from the full tree regardless of the current index.

## 2. Group by intent

Each group becomes exactly one commit. A group is everything that serves one purpose:

- Don't split one logical change across commits just because it touches several files.
- Don't merge unrelated purposes into one commit just because they touch the same file: split at the hunk level (`git add -p`, or write and apply a partial patch) when a single file mixes two intents.
- If the whole tree really is one intent, one commit is the correct output. Grouping doesn't mean forcing a split that isn't there.
- Where changes have a dependency order (a refactor a following feature builds on), commit them in that order.

This repo's own history never uses a `type(scope):` scope: match that unless a scope clearly earns its place. For a breaking change, mark it with `!` after the type (and/or a `BREAKING CHANGE:` footer).

## 3. Draft, then review before touching git state

Present the full plan: each group's files (or hunks) alongside its exact drafted commit message. Wait for explicit approval before running any `git add` or `git commit`. If changes are requested, revise the plan and present it again rather than applying part of it.

## 4. Apply

Once approved, work through the groups in order: stage exactly that group's files or hunks, commit with the reviewed message, then move to the next group. Finish by showing the resulting `git log` so the outcome is visible.

If the tree has no changes, say so and stop. There's nothing to group.
