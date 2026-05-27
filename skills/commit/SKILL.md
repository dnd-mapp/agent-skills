---
name: commit
description: Analyses all working-tree changes, groups them by intent, and creates well-formed Conventional Commits. Use when the user wants to commit changes, says "commit this", or needs staged, unstaged, and untracked work turned into structured commits.
---

# Commit

Groups all working-tree changes by intent and commits them using Conventional Commits format. Never pushes to remote.

## Workflow

1. **Collect changes** — run all three in parallel:

   - `git diff HEAD` (tracked modifications)
   - `git diff --cached` (already staged)
   - `git status --short` (untracked files)

2. **Group by intent** — identify logical groups across all changes. A single file may be split across commits when it contains changes of different intent. Use `git add -p` / patch-mode to stage exact hunks when partial file staging is needed.

3. **Draft commit messages** — for each group, produce a full message following the rules in [RULES.md](RULES.md).

4. **Present plan** — show all proposed commits with their full messages. Allow the user to edit any message before proceeding. Do not execute until the user approves the plan.

5. **Execute** — stage the exact hunks for each commit and run `git commit`. If a pre-commit hook fails on any commit, abort the entire plan immediately and report the failure.

## Defaults

| Concern            | Default                                     | Override                               |
|:-------------------|:--------------------------------------------|:---------------------------------------|
| Input scope        | Everything (staged + unstaged + untracked)  | "staged only", "this file only", etc.  |
| Untracked files    | Included                                    | "ignore untracked"                     |
| Push after commit  | Never                                       | —                                      |
