---
name: address-comments
description: Address existing comments on a pull request - review threads and general PR conversation comments - with code changes, replies, and resolutions, reviewed with you before anything is applied. Use when the user wants to respond to or resolve outstanding PR feedback, or when another skill needs a PR's comments addressed.
---

# Address Comments

Go through every unresolved review thread and unaddressed conversation comment on a pull request. For each, decide whether it needs a code change, a reply, or a follow-up ticket. Draft a combined plan and get your review, then make the changes, commit and push them, file any follow-up tickets, and post the replies and resolutions.

## 1. Resolve the PR

Optional PR number/URL argument; default to the current branch's open PR (`gh pr view`), the same convention `/pr` and `/review-comments` use. Stop with a clear message if neither is given and none is found.

Gather `number`, `baseRefName`, and `headRefName` via `gh pr view <number> --json number,baseRefName,headRefName`.

## 2. Set up the workspace

Work on the PR's actual branch, since this skill edits files and pushes. Check whether `headRefName` exists as a local branch (`git branch --list <headRefName>`):

- **Exists locally**: if the working tree isn't clean (`git status --porcelain`), stop and tell the user to commit or stash before re-running. Never stash or switch branches on their behalf. Otherwise `git checkout <headRefName>`, then `git fetch` and compare `HEAD` against its upstream. If the upstream has commits `HEAD` lacks, `git merge --ff-only`. Stop if the histories have diverged, since step 7.3's push would be rejected. If `HEAD` is level with or ahead of the upstream, proceed. Work here directly for the rest of this skill.
- **Doesn't exist locally** (never fetched, or a fork PR): create a throwaway worktree (`git worktree add --detach <path>`, detached so `git worktree add` doesn't leave a stray branch behind) in a scratch/temp directory named distinctly per PR, e.g. a `pr-<number>` subdirectory. Run `gh pr checkout <number>` inside it. This fetches the branch and configures its upstream and push target the same way an interactive checkout would, for a same-repo PR and a fork PR alike, so a plain `git push` in step 7.3 lands on the right repo and branch. Tear the worktree down once you no longer need it, regardless of outcome: step 7 finished, step 3 found no candidates, or the user rejected the plan at step 6. Run `git worktree remove <path>` (`--force` once for a dirty worktree, twice for a locked one). If that fails or leaves dangling metadata, run `git worktree remove --force <path>` followed by `git worktree prune -v`.

## 3. Gather comments to address

Fetch every review thread via GraphQL:

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            isOutdated
            comments(first: 100) {
              nodes { id databaseId author { login } body path line createdAt }
            }
          }
        }
      }
    }
  }' -f owner=<owner> -f repo=<repo> -F number=<number>
```

Keep threads where `isResolved` is `false`, regardless of author. A thread opened by a bot (this repo's own `review-comments` account included) is as much a candidate as one opened by a human. Paginate if the PR has more than 100 threads or a thread has more than 100 comments.

Each comment carries two IDs. `id` is the GraphQL node ID, used by `resolveReviewThread` in step 7.6. `databaseId` is the numeric REST ID, used by the reply call in step 7.5. Keep both.

Fetch general conversation comments too: `gh api repos/<owner>/<repo>/issues/<number>/comments`. Read them in order. Drop a comment if a later comment from the current `gh` identity (`gh api user --jq .login`) already answers it. Judge this by reading comprehension, never by matching nearby wording - the same standard `/review-comments` step 7 applies to its own dedup.

Everything remaining - unresolved threads and unaddressed general comments - is a candidate for step 4.

## 4. Decide each candidate's treatment

Read every candidate against `git diff <baseRefName>...HEAD` in the workspace from step 2, and decide one of:

- **Code change**: draft the change. In scope because the diff already touches the area, or because the fix is small enough that the extra scope isn't a real cost.
- **Reply only**: acknowledgment, disagreement, a clarifying question, or something already true. No code change.
- **Follow-up ticket**: the request is valid but belongs outside this PR - different files, unrelated behavior, or a change disproportionate to the PR's purpose. Runs through `/file-ticket` in step 7 instead of a code change here.
- **No action needed**: nothing to respond to - outdated (superseded by a later commit), already resolved by something else in this run, or not actually actionable. Still goes in the plan in step 5 with a one-line reason; nothing silently drops.

A review thread resolves only when the treatment fully satisfies it: a **Code change** that answers the comment, or a **Follow-up ticket** filed for it. **Reply only** never resolves the thread, including a pushback or clarifying reply - leave it open for the reviewer to close.

Draft each reply now. A reply to a general comment quotes the original text it's responding to, since nothing in the UI otherwise ties them together. A reply to a review thread doesn't, since GitHub already anchors it inline.

## 5. Draft the plan

One combined plan covering every candidate from step 4, in prose - no edits, no tickets, nothing posted yet. For each: its source (thread at `path:line`, or the general comment), the treatment, the drafted reply, and whether it resolves. Group by treatment or by file, whichever reads clearer for the number of candidates in this run.

Run the `writing-style` skill over every drafted reply before presenting the plan. Step 7.5 posts them through `gh`, and `writing-style` is the only review pass that path gets.

## 6. Review before making any changes

Present the plan. Wait for explicit approval before touching the working tree, the tracker, or GitHub. If changes are requested, revise and present the full plan again rather than applying part of it.

## 7. Apply

In order:

1. Make every approved code change in the workspace from step 2.
2. Run `/commit` to commit them.
3. Push with a plain `git push`, whichever setup step 2 used. A direct `git checkout` tracks the branch's remote, and `gh pr checkout` in the worktree configures the branch's upstream and push target (the fork's, for a cross-repository PR). This must land before any reply below references it.
4. Run `/file-ticket` once for every candidate marked **Follow-up ticket**. Each keeps its own draft-and-approve gate, the same way `/ship` sequences `/branch`, `/commit`, and `/pr` without adding a second gate on top.
5. Post every drafted reply:
   - Review thread: `gh api repos/<owner>/<repo>/pulls/<number>/comments/<comment_id>/replies --method POST -f body='<reply>'`, `<comment_id>` being the `databaseId` of the thread's first comment.
   - General comment: `gh api repos/<owner>/<repo>/issues/<number>/comments --method POST -f body='<reply>'`.
6. Resolve every thread marked for resolution:

   ```bash
   gh api graphql -f query='
     mutation($threadId: ID!) {
       resolveReviewThread(input: {threadId: $threadId}) { thread { isResolved } }
     }' -f threadId=<thread_id>
   ```

Show the PR URL and a one-line summary of what happened to each candidate.
