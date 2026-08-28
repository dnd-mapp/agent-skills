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

#### Review Thread

A GitHub inline review comment together with all of its replies, treated as one unit when checking whether a finding has already been raised on a PR. One of the shapes of prior bot feedback the dedup check matches against, alongside the bot's earlier review summaries and its general PR comments.\
_Avoid_: comment chain, discussion, comment

#### Review Summary

The top-level body text submitted with a GitHub PR review, separate from any inline thread or general PR comment. One of the shapes of prior bot feedback the dedup check matches against, and also the single top-level block `review-comments` drafts for its own review.\
_Avoid_: review body, top-level review body, review comment

#### General PR Comment

A comment on the pull request's conversation timeline, not attached to a line of the diff or submitted as part of a review. One of the shapes of prior bot feedback the dedup check matches against.\
_Avoid_: PR comment, issue comment, discussion comment

#### Addressed Finding

A new finding that matches prior feedback the bot itself posted on the PR: a Review Thread, an earlier Review Summary, or a General PR Comment. A thread counts as addressed when it's resolved or has a reply the agent judges as fixing it. A review summary or PR comment carries no resolved bit, so it counts as addressed only when the current diff or a later author reply visibly answers the point. Dropped from the draft; never posted again.\
_Avoid_: resolved finding, fixed finding

#### Open Finding

A new finding that matches prior bot feedback on the PR that nothing has resolved: an unresolved Review Thread, or a review-summary or PR-comment point the diff and later replies leave unanswered. Dropped from the draft to avoid duplicating the bot's own still-open point. Counted separately from Addressed Findings when `review-comments` reports what it suppressed, so the user can see it was intentionally skipped, not missed.\
_Avoid_: duplicate finding, repeat finding

#### New Finding

A finding that matches no prior bot feedback on the PR, or whose match is ambiguous. Drafted as a fresh comment: inline when it anchors to a file and line, otherwise folded into the review summary.\
_Avoid_: fresh finding

### Address Comments

#### Candidate

An unresolved review thread, an unaddressed general PR comment, or an unaddressed review summary, carried through the `address-comments` skill as one unit to be given a Treatment.\
_Avoid_: comment, item, finding

#### Treatment

The single decision made for one Candidate: a code change, a reply only, a follow-up ticket, or no action needed. Exactly one per Candidate, recorded in the plan even when it is "no action needed".\
_Avoid_: resolution, disposition, outcome
