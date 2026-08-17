---
name: review-comments
description: Run a code review against a pull request and draft one PR-level comment plus per-finding inline comments for you to approve, then post them as a single GitHub review under the configured account. Use when the user wants a PR reviewed and commented on GitHub, or when another skill needs review findings posted to a PR.
---

# Review Comments

Run `/code-review` against a pull request, draft one top-level review comment plus per-finding inline comments from its findings, get your approval, then post them as a single GitHub review under the configured account.

## 1. Load or bootstrap the repo config

Read [docs/agents/review-comments.md](../../docs/agents/review-comments.md) for the account to post as and the `suggested_event` default.

If that file doesn't exist yet, offer to create it:

- **Account**: ask which GitHub account to post reviews as (its username). It doesn't need to be authenticated locally yet; see step 3.
- **Suggested event**: propose `auto` (computed per-run, see step 6), shown to the user for confirmation like the drafted review itself. A fixed override (`approve` / `request_changes` / `comment`) is equally legitimate if the user prefers to always land on one event and adjust it manually at review time.

Once confirmed, write the file and ask whether to commit it on the current branch, folded into whatever this session is already about, or on a separate branch as its own PR. Either is legitimate, don't assume.

## 2. Resolve the PR

Optional PR number/URL argument; default to the current branch's open PR (`gh pr view`), mirroring `/pr`'s convention. Stop with a clear message if neither is given and none is found.

Gather `number`, `baseRefName`, `headRefName`, `headRefOid`, `headRepositoryOwner`, and `isCrossRepository` via `gh pr view <number> --json number,baseRefName,headRefName,headRefOid,headRepositoryOwner,isCrossRepository`.

## 3. Check the configured account's auth status

Check `gh auth status` for the account from step 1. If it isn't authenticated, surface a loud warning now (drafting still proceeds) so the user can go authenticate it while steps 4 through 7 run. Never skip this because the user says it's already authenticated; check it yourself. This is a heads-up only: the check that actually gates posting is the mandatory re-check in step 8.

## 4. Check out the PR into an isolated worktree

Never review inside the user's current checkout: isolate the PR in its own worktree instead.

```bash
git fetch origin refs/pull/<number>/head:pr-<number>
git worktree add <path> pr-<number>
```

This sequence is identical for same-repo and fork PRs; `isCrossRepository` and `headRepositoryOwner` from step 2 are for labeling only, not for choosing a different fetch. Put `<path>` in a scratch/temporary directory outside the repository: this agent's own scratch directory if it has one, otherwise the OS temp directory. Name it distinctly per PR (e.g. a `pr-<number>` subdirectory) so concurrent runs don't collide.

## 5. Run the code review

Invoke `/code-review` from inside the worktree, reviewing since `baseRefName` (the PR's merge-base), the same "changes since a fixed point" shape `/code-review` already expects.

## 6. Draft the comments

Read the diff and `/code-review`'s prose findings together, in the same context, and resolve each finding to a file and line yourself as a reading-comprehension step. Never mechanically parse the prose, and never fork `/code-review`'s own sub-agent briefs into a structured schema; it lives outside this repo and isn't reachable to change. A finding that can't anchor to a specific file+line goes into the top-level review body instead; every finding that can becomes its own inline comment. Don't force an inline comment where none applies, and don't skip the top-level body for findings that have nowhere else to go.

For `line`/`side` on each inline comment: an added or unchanged line gets `line` = its line number in the diff's new version, `side: RIGHT`; a deleted line gets `line` = its line number in the old version, `side: LEFT`.

Determine the review event:

- **`suggested_event: auto`**: zero findings → `APPROVE`; any hard Standards violation or a missing/wrong Spec requirement → `REQUEST_CHANGES`; anything else → `COMMENT`.
- **A fixed override** (`approve` / `request_changes` / `comment`): use it directly, no computation.

## 7. Draft, then review before touching GitHub

Present the account it'll post as, the PR, the suggested event, the top-level body, and every inline comment (file, line, side, text). Wait for explicit approval before posting anything. If changes are requested, revise and present the full draft again rather than applying part of it. The user can also override the suggested event here regardless of how it was computed.

## 8. Apply

Re-check `gh auth status` for the configured account right now, even though step 3 already checked it. Never trust that earlier check or the user's word at this point. If a different account is currently active, `gh auth switch --user <configured account>`, remembering whichever account was active before.

Build the review payload and post it as one atomic call:

```bash
gh api repos/<owner>/<repo>/pulls/<number>/reviews --method POST --input - <<'EOF'
{"commit_id": "<headRefOid>", "event": "<EVENT>", "body": "<top-level body>", "comments": [{"path": "<path>", "line": <line>, "side": "<RIGHT|LEFT>", "body": "<text>"}]}
EOF
```

Omit `comments` entirely (rather than an empty array) when no finding anchored to a file+line.

Switch back to whichever account was active before this step, whether or not the post succeeded.

Tear down the worktree regardless of outcome: `git worktree remove <path>` (`--force` once for a dirty worktree, twice for a locked one). If the run failed partway and the worktree is gone or its metadata is left dangling, run `git worktree remove --force <path>` followed by `git worktree prune -v` instead.

Show the resulting review URL.
