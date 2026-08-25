---
name: pr
description: Draft a pull request for the current branch (title, description, related issues, and checklist derived from the diff), reviewed with you before opening it with `gh pr create`. Use when the user wants to open or update a pull request, or when another skill needs one opened.
---

# PR

Open a pull request for the current branch: draft a title and description from the diff against the target branch, fill in the repo's PR template, get your review, then create it with `gh pr create`.

## 1. Load or bootstrap the repo config

Read [docs/agents/pull-requests.md](../../docs/agents/pull-requests.md) for this repo's target branch, direct-push policy, draft-by-default, and PR template location.

If that file doesn't exist yet, offer to create it:

- **Target branch**: the repo's actual default branch (`gh repo view --json defaultBranchRef`).
- **Direct push to target branch**: infer from GitHub branch protection on that branch (`gh api repos/<owner>/<repo>/branches/<branch>/protection`). Protected with required pull requests → "not allowed". No protection configured → don't assume "allowed"; ask instead.
- **Draft by default**: propose `false`, shown to the user for confirmation like the drafted PR itself.
- **PR template**: check this repo for its own `.github/PULL_REQUEST_TEMPLATE.md` first; if it has none, check `<owner>/.github` for the same path (GitHub's own repo-then-org resolution order). Ask if neither exists.

Once confirmed, write the file and ask whether to commit it on the current branch, folded into the PR this session is about to open, or on a separate branch as its own PR. Either is legitimate, don't assume.

## 2. Fetch the template

Fetch the raw content of the template located in step 1, before drafting anything, so the description and related-issues steps below know what sections to write for. An org-level template lives in a different repo than the one being worked in, so `gh pr create` can't resolve it on its own: fetch it directly, e.g. `gh api -H "Accept: application/vnd.github.raw+json" repos/<owner>/.github/contents/.github/PULL_REQUEST_TEMPLATE.md`.

## 3. Check for an existing PR

Check whether the current branch already has an open PR (`gh pr view`). If one does, this run refreshes it: resolve steps 4 through 7 as usual, then use `gh pr edit` instead of `gh pr create` in step 10, rather than failing on a duplicate-PR error.

## 4. Derive the title

Derive a Conventional Commits `type(scope): description` title, in the imperative mood, from `git diff <target>...HEAD`, the same way `/branch` derives a type from a diff. Read the diff itself, not the branch's commit messages: the title needs to hold up even in a repo where commits don't follow Conventional Commits.

## 5. Derive the description

From the same diff, draft what changed and why, written to fit whatever summary-style section the template fetched in step 2 defines. Again read the diff, not the commit messages, for the same portability reason as the title.

Write it as flowing paragraphs, not hard-wrapped like a `/commit` body: GitHub renders this as Markdown, so wrapped source lines just add noise without changing how it displays.

## 6. Find related issues

Look for `Closes:`, `Refs:`, or `Resolves:` trailers across the branch's commits (`git log <target>..HEAD`), `/commit`'s own vocabulary, and re-emit them as PR-level closing keywords (`Closes #123`, `Refs #123`) fitted to the template's related-issues section. If none are found, fall back to a leading issue number in the branch name, `/branch`'s convention.

## 7. Assemble the body

Fill the template's sections with the description and related issues drafted above.

For the checklist, tick a line only when its condition is verifiably met:

- title and description already follow the guide: always true, they were drafted to it directly
- commits follow Conventional Commits: true only if every commit on the branch matches `type(scope): subject`
- tests or docs were updated: true only if the diff touches a path matching a test or doc glob
- anything about CI checks passing: never tick, CI hasn't run yet at draft time
- anything else the wording doesn't clearly match one of the above: leave unchecked

## 8. Run writing-style

Run the `writing-style` skill over the drafted title and body before presenting them in the next step.

## 9. Draft, then review before touching git state

Present the title, body, base branch, and whether it'll open as a draft: draft if asked for at invocation, otherwise the config's draft-by-default. Wait for explicit approval before pushing or creating anything.

## 10. Apply

Push the branch if it has no upstream yet (`git push -u origin <branch>`), required since `gh pr create` aborts instead of prompting when run non-interactively. Then:

- **New PR** (step 3 found none): `gh pr create --title "<title>" --body-file - --base <target>`, adding `--draft` if step 9 settled on draft, piping the reviewed body in over stdin.
- **Existing PR** (step 3 found one): `gh pr edit <number> --title "<title>" --body-file -` instead.

Show the resulting PR URL.
