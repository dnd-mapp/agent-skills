---
name: branch
description: Create a git branch named for the work about to happen, deriving the type and slug from the diff, a known issue, or a description. Use when the user wants to start new work or asks to create a branch, or when another skill needs a branch before it can proceed.
---

# Branch

Create a new git branch named for the work it's about to hold, following this org's [branch naming convention](https://wiki.dndmapp.nl.eu.org/development-conventions/branch-naming): `<type>/<slug>`, or `<type>/<issue-number>-<slug>` when the branch is for a tracked GitHub issue.

## 1. Determine type and slug

Prefer, in order:

1. **The diff.** If the working tree already has staged or unstaged changes, derive the type and slug from `git diff` and `git diff --staged` together, reading the actual change rather than just file names. If the diff clearly mixes unrelated intents (the kind the `commit` skill would split into separate commits), don't guess at a dominant one: ask what the branch is for.
2. **A known issue.** If a GitHub issue number was given in conversation or at invocation, use its title to inform word choice for the slug.
3. **A description.** If there's no diff and no issue, ask what the branch is for and derive the type and slug from the answer.

The `<type>` is one of the [Conventional Commits](https://www.conventionalcommits.org/) types (`feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`), the same vocabulary the `commit` skill uses.

The `<slug>` follows the same quality bar as a commit subject: lowercase, kebab-case, specific enough to distinguish this branch from another of the same type (`add-login-flow`, not `fix-bug`).

## 2. Determine the base branch

Detect the repo's default branch (`main` or `master`) rather than assuming.

- **On the default branch already**: update it (`git pull --ff-only` or equivalent) before branching, so the new branch starts from its latest commit.
- **On another branch**: ask which of three options to take. Switch to the default branch (updating it first) and branch from there. Branch from the current branch anyway, for intentional stacked work. Or stop and leave it to be handled manually. Each is a legitimate workflow; don't assume.

## 3. Create the branch

Combine type, optional issue number, and slug into the branch name, then create it locally (`git checkout -b <name>` or `git switch -c <name>`) from the base branch determined in step 2.

Never push the branch or set upstream tracking. That happens later, alongside the first commit or push, not here.
