# agent-skills

Claude Code Agent Skills and Subagent definitions built for the `dnd-mapp` organization. Skills are written to the open Agent Skills standard, so they're portable beyond Claude Code; subagents are Claude Code-specific, since no equivalent portable format exists yet.

## Language

### Agent Skill

On-demand instructions (a `SKILL.md` plus supporting files) that an agent loads into its current context when the task matches, extending what it knows how to do in place.\
_Avoid_: skill file, plugin

### Subagent

A separately-configured Claude Code agent (own system prompt, tools, model) that the main agent dispatches work to; it runs in an isolated context and reports a result back.\
_Avoid_: sub-agent, agent (too generic), task

### File Ticket

#### Operation

A named, tracker-agnostic step a skill's `SKILL.md` calls by name (e.g. `resolve-target-repo`, `create-ticket`), whose concrete mechanics live in a per-integration file such as `skills/<name>/operations/<tracker>.md`, selected by the repo's configured tracker.\
_Avoid_: step, action, command

#### Template Candidate

One issue-template option surfaced when filing a ticket, uniformly shaped (`{name, about, raw content}`) regardless of whether the source is a legacy Markdown template, a Markdown chooser entry, or a YAML issue form.\
_Avoid_: template

### Review Comment Dedup

#### Prior Feedback

Review comments the configured account itself already posted on a PR, in any of three shapes: a Review Thread, a Review Summary, or a General PR Comment. `review-comments` matches each new finding against this whole set when deciding whether it has already been raised.\
_Avoid_: earlier feedback, past comments

#### Review Thread

A GitHub inline review comment together with all of its replies, treated as one unit when checking whether a finding has already been raised on a PR. One shape of Prior Feedback.\
_Avoid_: comment chain, discussion, comment

#### Review Summary

The overall body text of a GitHub PR review, separate from any inline thread or general PR comment. One shape of Prior Feedback, and also the single review-summary block `review-comments` drafts for its own review.\
_Avoid_: review body, top-level review body, review comment

#### General PR Comment

A comment on the pull request's conversation timeline, not attached to a line of the diff or submitted as part of a review. One shape of Prior Feedback.\
_Avoid_: issue comment, discussion comment

#### Addressed Finding

A new finding that matches Prior Feedback the configured account posted on the PR. A thread signals it was handled through resolution or a reply. A Review Summary or General PR Comment carries no resolved bit, so it signals through the current diff or a later reply. The `review-comments` skill carries the operative rule. Dropped from the draft; never posted again.\
_Avoid_: resolved finding, fixed finding

#### Open Finding

A new finding that matches unresolved Prior Feedback from the configured account on the PR. The match is an unresolved Review Thread, or a Review Summary or General PR Comment point that the `review-comments` skill finds still unanswered. Dropped from the draft to avoid duplicating the account's own still-open point. Counted separately from Addressed Findings when `review-comments` reports what it suppressed, so the user can see it was intentionally skipped, not missed.\
_Avoid_: duplicate finding, repeat finding

#### New Finding

A finding that matches no prior feedback from the configured account on the PR, or whose match is ambiguous. Drafted as a fresh comment: inline when it anchors to a file and line, otherwise folded into the review summary.\
_Avoid_: fresh finding

### Address Comments

#### Candidate

An unresolved review thread, an unaddressed general PR comment, or an unaddressed review summary, carried through the `address-comments` skill as one unit to be given a Treatment.\
_Avoid_: comment, item, finding

#### Treatment

The single decision made for one Candidate: a code change, a reply only, a follow-up ticket, or no action needed. Exactly one per Candidate, recorded in the plan even when it is "no action needed".\
_Avoid_: resolution, disposition, outcome
