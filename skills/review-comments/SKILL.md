---
name: review-comments
description: Review a PR and post comments to GitHub. Use when the user wants a PR reviewed and commented on GitHub, or when another skill needs review findings posted to a PR.
---

# Review Comments

Run `/code-review` against a pull request, then draft one top-level review body plus per-finding inline comments from its findings. Exclude anything the configured account already raised on the PR, whether in a review thread, an earlier review body, or a general PR comment, that's since been addressed or that's still sitting unresolved from an earlier run. Get your approval, then post the draft as a single GitHub review under the configured account.

## 1. Load or bootstrap the repo config

Read [docs/agents/review-comments.md](../../docs/agents/review-comments.md) for the account to post as and the `suggested_event` default.

If that file doesn't exist yet, offer to create it:

- **Account**: ask which GitHub account to post reviews as (its username). It doesn't need to be authenticated locally yet; see step 4.
- **Suggested event**: propose `auto` (computed per-run, see step 7), shown to the user for confirmation like the drafted review itself. A fixed override (`approve` / `request_changes` / `comment`) is equally legitimate if the user prefers to always land on one event and adjust it manually at review time.

Once confirmed, write the file and ask whether to commit it on the current branch, folded into whatever this session is already about, or on a separate branch as its own PR. Either is legitimate, don't assume.

## 2. Resolve the PR

Optional PR number/URL argument; default to the current branch's open PR (`gh pr view`), mirroring `/pr`'s convention. Stop with a clear message if neither is given and none is found.

Gather `number`, `baseRefName`, `headRefName`, `headRefOid`, and `url` via `gh pr view <number> --json number,baseRefName,headRefName,headRefOid,url`.

`<owner>` and `<repo>` for every API call in this skill come from the PR's `url` (`https://github.com/<owner>/<repo>/pull/<number>`). Take them from there, not from `gh repo view` or the local clone's remotes, which can point at a different repo than the one the PR lives on. This skill assumes the PR is on the repo itself, not a fork.

## 3. Fetch this account's prior feedback on the PR

Before anything else, look up everything the account from step 1 has already posted on this PR: its inline review threads, its top-level review bodies, and its general PR comments. Cover all of its past reviews, not just the most recent one. A finding it once made only in a review body, with no inline thread, still needs to dedupe against this run. This is an independent read with nothing to wait on. Kick it off now rather than adjacent to step 7 where it's used, so it can run while steps 4 through 6 (auth check, worktree setup, code review) proceed.

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          pageInfo { hasNextPage endCursor }
          nodes {
            id
            isResolved
            comments(first: 100) {
              pageInfo { hasNextPage endCursor }
              nodes { author { login } body url createdAt }
            }
          }
        }
        reviews(first: 100) {
          pageInfo { hasNextPage endCursor }
          nodes { author { login } body state url submittedAt }
        }
        comments(first: 100) {
          pageInfo { hasNextPage endCursor }
          nodes { author { login } body url createdAt }
        }
      }
    }
  }' -f owner=<owner> -f repo=<repo> -F number=<number>
```

Across all three lists, keep only what the account from step 1 authored: review threads it started (its login on the first comment), review bodies it submitted, and PR comments it wrote. For each kept thread, record whether it's resolved and the full text of every reply. For each kept review body and PR comment, record its full text. A thread, review, or comment from a human reviewer isn't in scope; this only dedupes against the account's own prior output.

Each of the three top-level connections returns `pageInfo`: when `hasNextPage` is true, follow `endCursor` to fetch the rest before drafting. The nested `comments` connection takes no cursor here, so a thread with more than 100 comments needs a follow-up query keyed by its `id`:

```bash
gh api graphql --paginate -f query='
  query($threadId: ID!, $endCursor: String) {
    node(id: $threadId) {
      ... on PullRequestReviewThread {
        comments(first: 100, after: $endCursor) {
          pageInfo { hasNextPage endCursor }
          nodes { author { login } body url createdAt }
        }
      }
    }
  }' -f threadId=<thread_id>
```

If this call fails (rate limit, transient API error, etc.), surface a loud warning and proceed as if the account has no prior feedback on this PR. This is the same warn-and-continue pattern as step 4's auth check. The only cost is this run falling back to today's behavior (no dedup), not a new failure mode.

## 4. Check the configured account's auth status

Check `gh auth status` for the account from step 1. If it isn't authenticated, surface a loud warning now (drafting still proceeds) so the user can go authenticate it while steps 5 through 9 run. Never skip this because the user says it's already authenticated; check it yourself. This is a heads-up only: the check that actually gates posting is the mandatory re-check in step 10.

## 5. Check out the PR into an isolated worktree

Never review inside the user's current checkout: isolate the PR in its own worktree instead.

```bash
git fetch origin refs/pull/<number>/head:pr-<number>
git worktree add <path> pr-<number>
```

This fetches the PR head into a local `pr-<number>` ref and checks it out in a worktree. It assumes `origin` is the repo the PR lives on, the same as the rest of this skill. Put `<path>` in a scratch/temporary directory outside the repository: this agent's own scratch directory if it has one, otherwise the OS temp directory. Name it distinctly per PR (e.g. a `pr-<number>` subdirectory) so concurrent runs don't collide.

## 6. Run the code review

Invoke `/code-review` from inside the worktree, reviewing since `baseRefName` (the PR's merge-base), the same "changes since a fixed point" shape `/code-review` already expects.

## 7. Draft the comments

Read the diff and `/code-review`'s prose findings together, in the same context. Never mechanically parse the prose, and never fork `/code-review`'s own sub-agent briefs into a structured schema. It lives outside this repo and isn't reachable to change.

Run every finding through this dedup check before drafting anything from it. Match it by reading comprehension against all of the account's prior feedback from step 3: its review threads, its earlier review bodies, and its PR comments. Never match on line number, since lines drift between commits. Classify each finding:

- **Addressed Finding**: matches a resolved thread, a thread with a reply you judge as fixing it, or a point from a past review body or PR comment that the current diff or a later author reply resolves. Drop it.
- **Open Finding**: matches an unresolved thread, or a past review-body or PR-comment point that nothing has resolved. Drop it too, since re-posting the account's own live point is the same noise. Keep it in a list separate from Addressed Findings for step 9.
- **New Finding**: the match is ambiguous, or there is none. Draft it. When unsure, don't suppress: a missed regression is worse than an occasional duplicate.

Never write to a matched thread itself in this step. Addressed and Open Findings are dropped from this run's draft only, nothing is posted back to the old thread.

For each New Finding, resolve it to a file and line yourself as a reading-comprehension step. One that anchors to a specific file+line becomes an inline comment; one that can't goes into the top-level review body. Don't force an inline comment where none applies.

The top-level body carries only substantive review content: New Findings with no inline anchor, and a one or two sentence overall verdict. It reads as a PR review, not a run log. That excludes the methodology (`/code-review`, the two axes, the worktree) and the dedup bookkeeping (which prior threads exist, what was suppressed, how thorough the earlier rounds were). When there are no unanchored findings and the verdict is a plain approve, one sentence is the whole body.

For `line`/`side` on each New Finding's inline comment: an added or unchanged line gets `line` = its line number in the diff's new version, `side: RIGHT`; a deleted line gets `line` = its line number in the old version, `side: LEFT`.

Determine the review event:

- **`suggested_event: auto`**: zero New Findings (inline or top-level) → `APPROVE`; any hard Standards violation or a missing/wrong Spec requirement among them → `REQUEST_CHANGES`; anything else → `COMMENT`.
- **A fixed override** (`approve` / `request_changes` / `comment`): use it directly, no computation.

## 8. Run writing-style

Run the `writing-style` skill over the drafted top-level body and every inline comment before presenting them in the next step.

## 9. Draft, then review before touching GitHub

Present the account it'll post as, the PR, the suggested event, the top-level body, and every inline comment (file, line, side, text). This is what will be posted.

Then, separate from what gets posted, give a one-line summary of what step 7 suppressed: the counts of Addressed and Open Findings. Example: "Suppressed 6 findings matching prior feedback (5 addressed, 1 open)." List them individually only if the user asks.

Wait for explicit approval before posting anything. If changes are requested, revise and present the full draft again rather than applying part of it. The user can also override the suggested event here regardless of how it was computed.

## 10. Apply

Re-check `gh auth status` right now, even though step 4 already checked it. Never trust that earlier check or the user's word at this point. One `gh auth status` call reports both the configured account's auth state and which account is currently active. If a different account is active, note it for the switch-back below, then `gh auth switch --user <configured account>`.

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
