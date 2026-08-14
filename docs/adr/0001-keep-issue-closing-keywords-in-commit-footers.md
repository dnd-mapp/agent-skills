# Keep GitHub issue-closing keywords in commit footers even though they don't close anything from there

The `commit` skill's footer guidance includes `Closes:` (and GitHub's other issue-closing keywords). GitHub only registers a closing keyword as a linked issue when it appears in a **PR description**: the same keyword in a commit message has no effect on GitHub's side (see the org's own [PR conventions wiki](https://github.com/dnd-mapp/wiki/blob/main/pages/development-conventions/creating-a-pull-request.md), which states this explicitly). We decided to keep using them in commit footers anyway: even though GitHub won't act on a `Closes:` footer in a commit message, it still communicates intent to a human reading `git log`, and that's a value independent of whether GitHub's automation triggers on it.

## Considered Options

Steer the skill away from `Closes:`/`Fixes:`/`Resolves:` in commit footers entirely, reserving them for the PR description where they actually register, and using only non-closing tokens (`Refs:`) in commits. Rejected: it would strip a signal that's still meaningful to a human reading commit history, purely because GitHub itself ignores it in that location.

## Consequences

A future reader (human or agent) skimming an individual commit will see `Closes: #N` and may assume it closed the issue on merge; it didn't. The PR description is what does that (or will, if the PR also carries the keyword). This ADR exists so that gap doesn't get "fixed" by someone re-adding the guardrail without knowing it was deliberate.
