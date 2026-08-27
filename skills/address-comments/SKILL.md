---
name: address-comments
description: Address existing comments on a pull request (review threads and general PR conversation comments) with code changes, replies, and resolutions, reviewed with you before anything is applied. Use when the user wants to respond to or resolve outstanding PR feedback, or when another skill needs a PR's comments addressed.
---

# Address Comments

Go through every unresolved review thread and unaddressed conversation comment on a pull request. For each, decide whether it needs a code change, a reply, or a follow-up ticket. Draft a combined plan and get your review, then make the changes, commit and push them, file any follow-up tickets, and post the replies and resolutions.

## 1. Resolve the PR

Optional PR number/URL argument; default to the current branch's open PR (`gh pr view`), the same convention `/pr` and `/review-comments` use. Stop with a clear message if neither is given and none is found.

Gather `number`, `baseRefName`, and `headRefName` via `gh pr view <number> --json number,baseRefName,headRefName`.

## 2. Set up the workspace

Work on the PR's actual branch, since this skill edits files and pushes. Check whether `headRefName` exists as a local branch (`git branch --list <headRefName>`):

- **Exists locally**:
  - If the working tree isn't clean (`git status --porcelain`), stop and tell the user to commit or stash before re-running. Never stash or switch branches on their behalf.
  - Record the branch the user is currently on.
  - `git checkout <headRefName>`, then `git fetch` and compare `HEAD` against its upstream.
  - If the upstream has commits `HEAD` lacks, `git merge --ff-only`. Stop if the histories have diverged, since step 7.3's push would be rejected.
  - Otherwise `HEAD` is level with or ahead of the upstream. Proceed, and work here directly for the rest of this skill.
  - If `git checkout` moved the user off another branch, the step 7 summary must say they were left on `<headRefName>`. Don't switch them back on their behalf.
- **Doesn't exist locally** (never fetched, or a fork PR):
  - Create a throwaway worktree with `git worktree add --detach <path>`. The `--detach` stops `git worktree add` from leaving a stray branch behind. Put `<path>` in a scratch or temp directory named distinctly per PR, e.g. a `pr-<number>` subdirectory.
  - Run `gh pr checkout <number>` inside it. This fetches the branch and configures its upstream and push target the way an interactive checkout would, for a same-repo PR and a fork PR alike. A plain `git push` in step 7.3 then lands on the right repo and branch.
  - Run the rest of this skill from inside the worktree, steps 4 and 7 included, so `/commit` and `git push` act on it and not the user's main checkout.
  - Tear the worktree down once you no longer need it, regardless of outcome: step 7 finished, step 3 found no candidates, or the user rejected the plan at step 6.
  - Run `git worktree remove <path>` (`--force` once for a dirty worktree, twice for a locked one). If that fails or leaves dangling metadata, run `git worktree remove --force <path>` followed by `git worktree prune -v`.

## 3. Gather comments to address

Fetch every review thread via GraphQL:

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
            isOutdated
            comments(first: 100) {
              pageInfo { hasNextPage endCursor }
              nodes { databaseId author { login } body path line createdAt }
            }
          }
        }
      }
    }
  }' -f owner=<owner> -f repo=<repo> -F number=<number>
```

Keep threads where `isResolved` is `false`, regardless of author. A thread opened by a bot (this repo's own `review-comments` account included) is as much a Candidate as one opened by a human. Follow the `pageInfo` cursors while `hasNextPage` is true, on `reviewThreads` for a PR with more than 100 threads and on `comments` for a thread with more than 100 comments.

Keep two IDs per thread. The thread-level `id` on `reviewThreads.nodes` is the GraphQL node ID that step 7.6 passes to `resolveReviewThread`. Each comment's `databaseId` is the numeric REST ID, and step 7.5's reply call takes the `databaseId` of the thread's first comment.

Fetch general conversation comments too: `gh api --paginate repos/<owner>/<repo>/issues/<number>/comments` (without `--paginate` this returns only the first 30). Read them in order. Drop a comment if a later comment from the current `gh` identity (`gh api user --jq .login`) already answers it. Judge this by reading comprehension, never by matching nearby wording. This is the same standard `/review-comments` step 7 applies to its own dedup.

Everything remaining (unresolved threads and unaddressed general comments) is a Candidate for step 4.

## 4. Decide each Candidate's Treatment

Read every Candidate against the PR's diff in the workspace from step 2, then decide one Treatment.

First run `git fetch origin <baseRefName>`, then diff with `git diff origin/<baseRefName>...HEAD`. The worktree path fetches only the PR head, and a local `<baseRefName>` branch can be missing or stale. A bare `<baseRefName>` would compare against the wrong base.

The Treatments:

- **Code change**: draft the change. In scope because the diff already touches the area, or because the fix is small enough that the extra scope isn't a real cost.
- **Reply only**: acknowledgment, disagreement, a clarifying question, or something already true. No code change.
- **Follow-up ticket**: the request is valid but belongs outside this PR: different files, unrelated behavior, or a change disproportionate to the PR's purpose. Runs through `/file-ticket` in step 7 instead of a code change here.
- **No action needed**: nothing to respond to. Outdated (superseded by a later commit), already resolved by something else in this run, or not actually actionable. Still goes in the plan in step 5 with a one-line reason, so nothing silently drops.

A review thread resolves only when the Treatment fully satisfies it: a **Code change** that answers the comment, or a **Follow-up ticket** filed for it. **Reply only** never resolves the thread, including a pushback or clarifying reply. Leave it open for the reviewer to close.

Draft each reply now. A reply to a general comment quotes the original text it's responding to, since nothing in the UI otherwise ties them together. A reply to a review thread doesn't, since GitHub already anchors it inline. A reply for a **Follow-up ticket** Candidate names the issue it will cite with a placeholder, since the issue doesn't exist until step 7.4. Step 7.5 splices in the real number and URL before posting.

## 5. Draft the plan

One combined plan covering every Candidate from step 4, in prose: no edits, no tickets, nothing posted yet. For each: its source (thread at `path:line`, or the general comment), the Treatment, the drafted reply, and whether it resolves. Group by Treatment or by file, whichever reads clearer for the number of Candidates in this run.

Run the `writing-style` skill over every drafted reply before presenting the plan. Step 7.5 posts them through `gh`, and `writing-style` is the only review pass that path gets.

## 6. Review before making any changes

Present the plan. Wait for explicit approval before touching the working tree, the tracker, or GitHub. If changes are requested, revise and present the full plan again rather than applying part of it.

## 7. Apply

Check `gh auth status` first. Every step below pushes or posts as the active `gh` account: the push, the follow-up tickets, the replies, and the thread resolutions. Surface a warning and stop if it isn't authenticated, or if the active account isn't the one the user wants to act as.

Then, in order:

1. Make every approved code change in the workspace from step 2.
2. Run `/commit` to commit them.
3. Push with a plain `git push`, whichever setup step 2 used. A direct `git checkout` tracks the branch's remote, and `gh pr checkout` in the worktree configures the branch's upstream and push target (the fork's, for a cross-repository PR). This must land before any reply below references it.
4. Run `/file-ticket` once for every Candidate marked **Follow-up ticket**. Each keeps its own draft-and-approve gate, the same way `/ship` sequences `/branch`, `/commit`, and `/pr` without adding a second gate on top. Note the issue number and URL each run produces.
5. Post every drafted reply. For a **Follow-up ticket** reply, replace the step 4 placeholder with the real issue number and URL first:
   - Review thread: `gh api repos/<owner>/<repo>/pulls/<number>/comments/<comment_id>/replies --method POST -f body='<reply>'`, `<comment_id>` being the `databaseId` of the thread's first comment.
   - General comment: `gh api repos/<owner>/<repo>/issues/<number>/comments --method POST -f body='<reply>'`.
6. Resolve every thread marked for resolution:

   ```bash
   gh api graphql -f query='
     mutation($threadId: ID!) {
       resolveReviewThread(input: {threadId: $threadId}) { thread { isResolved } }
     }' -f threadId=<thread_id>
   ```

Show the PR URL and a one-line summary of what happened to each Candidate. If step 2 checked out `<headRefName>` from another branch, say the user was left on it.
