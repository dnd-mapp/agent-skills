---
name: review-comments
description: Review a PR and post comments to GitHub. Use when the user wants a PR reviewed and commented on GitHub, or when another skill needs review findings posted to a PR.
---

# Review Comments

Run `/code-review` against a pull request, then draft one top-level review comment plus per-finding inline comments from its findings. Exclude anything the configured account already raised that's since been addressed, or that's still sitting unresolved from an earlier run. Get your approval, then post the draft as a single GitHub review under the configured account.

## 1. Load or bootstrap the repo config

Read [docs/agents/review-comments.md](../../docs/agents/review-comments.md) for the account to post as and the `suggested_event` default.

If that file doesn't exist yet, offer to create it:

- **Account**: ask which GitHub account to post reviews as (its username). It doesn't need to be authenticated locally yet; see step 4.
- **Suggested event**: propose `auto` (computed per-run, see step 7), shown to the user for confirmation like the drafted review itself. A fixed override (`approve` / `request_changes` / `comment`) is equally legitimate if the user prefers to always land on one event and adjust it manually at review time.

Once confirmed, write the file and ask whether to commit it on the current branch, folded into whatever this session is already about, or on a separate branch as its own PR. Either is legitimate, don't assume.

## 2. Resolve the PR

Optional PR number/URL argument; default to the current branch's open PR (`gh pr view`), mirroring `/pr`'s convention. Stop with a clear message if neither is given and none is found.

Gather `number`, `baseRefName`, `headRefName`, `headRefOid`, `headRepositoryOwner`, and `isCrossRepository` via `gh pr view <number> --json number,baseRefName,headRefName,headRefOid,headRepositoryOwner,isCrossRepository`.

## 3. Fetch this account's prior review threads

Before anything else, look up every review thread the account from step 1 has already posted on this PR, across all of its past reviews, not just the most recent one. This is an independent read with nothing to wait on. Kick it off now rather than adjacent to step 7 where it's used, so it can run while steps 4 through 6 (auth check, worktree setup, code review) proceed.

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            comments(first: 100) {
              nodes { author { login } body url createdAt }
            }
          }
        }
      }
    }
  }' -f owner=<owner> -f repo=<repo> -F number=<number>
```

Keep only threads whose first comment's author matches the account from step 1. A thread a human reviewer started isn't in scope; this only dedupes against the bot's own prior output. For each kept thread, record whether it's resolved and the full text of every reply. Paginate if a PR has more than 100 threads or a thread has more than 100 comments.

If this call fails (rate limit, transient API error, etc.), surface a loud warning and proceed as if no prior threads exist. This is the same warn-and-continue pattern as step 4's auth check. The only cost is this run falling back to today's behavior (no dedup), not a new failure mode.

## 4. Check the configured account's auth status

Check `gh auth status` for the account from step 1. If it isn't authenticated, surface a loud warning now (drafting still proceeds) so the user can go authenticate it while steps 5 through 8 run. Never skip this because the user says it's already authenticated; check it yourself. This is a heads-up only: the check that actually gates posting is the mandatory re-check in step 10.

## 5. Check out the PR into an isolated worktree

Never review inside the user's current checkout: isolate the PR in its own worktree instead.

```bash
git fetch origin refs/pull/<number>/head:pr-<number>
git worktree add <path> pr-<number>
```

This sequence is identical for same-repo and fork PRs. `isCrossRepository` and `headRepositoryOwner` from step 2 are for labeling only, not for choosing a different fetch. Put `<path>` in a scratch/temporary directory outside the repository: this agent's own scratch directory if it has one, otherwise the OS temp directory. Name it distinctly per PR (e.g. a `pr-<number>` subdirectory) so concurrent runs don't collide.

## 6. Run the code review

Invoke `/code-review` from inside the worktree, reviewing since `baseRefName` (the PR's merge-base), the same "changes since a fixed point" shape `/code-review` already expects.

## 7. Draft the comments

Read the diff and `/code-review`'s prose findings together, in the same context, and resolve each finding to a file and line yourself as a reading-comprehension step. Never mechanically parse the prose, and never fork `/code-review`'s own sub-agent briefs into a structured schema. It lives outside this repo and isn't reachable to change. A finding that can't anchor to a specific file+line goes into the top-level review body instead; every finding that can proceeds to the dedup check below. Don't force an inline comment where none applies, and don't skip the top-level body for findings that have nowhere else to go.

For every finding that anchors to a file+line, check it by reading comprehension against the threads gathered in step 3. Never match mechanically on line number, since lines drift between commits:

- Matches a thread that's resolved, or has a reply you judge as fixing it: an **Addressed Finding**. Drop it; no inline comment.
- Matches a thread that's neither resolved nor addressed by a reply: an **Open Finding**. Also drop it, to avoid re-posting a duplicate of the account's own still-open comment. Keep it in a separate list from Addressed Findings for step 9.
- Ambiguous match, or no match at all: a **New Finding**. Draft it normally. When in doubt, don't suppress: a missed regression is worse than an occasional duplicate.

Never write to the matched thread itself in this step; Addressed and Open Findings are dropped from this run's draft only, nothing is posted back to the old thread.

For `line`/`side` on each New Finding's inline comment: an added or unchanged line gets `line` = its line number in the diff's new version, `side: RIGHT`; a deleted line gets `line` = its line number in the old version, `side: LEFT`.

Determine the review event:

- **`suggested_event: auto`**: zero New Findings (inline or top-level) → `APPROVE`; any hard Standards violation or a missing/wrong Spec requirement among them → `REQUEST_CHANGES`; anything else → `COMMENT`.
- **A fixed override** (`approve` / `request_changes` / `comment`): use it directly, no computation.

## 8. Run writing-style

Run the `writing-style` skill over the drafted top-level body and every inline comment before presenting them in the next step.

## 9. Draft, then review before touching GitHub

Present the account it'll post as, the PR, the suggested event, the top-level body, and every inline comment (file, line, side, text). This is what will be posted. Also present, for visibility only and never as part of what gets posted, the Addressed Findings and Open Findings from step 7. A short reference to each old thread is enough, not a full requote. The point is letting the user see what was suppressed and why. Wait for explicit approval before posting anything. If changes are requested, revise and present the full draft again rather than applying part of it. The user can also override the suggested event here regardless of how it was computed.

## 10. Apply

Re-check `gh auth status` for the configured account right now, even though step 4 already checked it. Never trust that earlier check or the user's word at this point. If a different account is currently active, `gh auth switch --user <configured account>`, remembering whichever account was active before.

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
