# agent-skills

Claude Code Agent Skills and Subagent definitions built for the `dnd-mapp` organization. Skills are written to the open Agent Skills standard, so they're portable beyond Claude Code; subagents are Claude Code-specific, since no equivalent portable format exists yet.

## Language

### Agent Skill

On-demand instructions (a `SKILL.md` plus supporting files) that an agent loads into its current context when the task matches, extending what it knows how to do in place.\
_Avoid_: skill file, plugin

### Subagent

A separately-configured Claude Code agent (own system prompt, tools, model) that the main agent dispatches work to; it runs in an isolated context and reports a result back.\
_Avoid_: sub-agent, agent (too generic), task

### Review Comment Dedup

#### Review Thread

A GitHub inline review comment together with all of its replies, treated as one unit when checking whether a finding has already been raised on a PR.\
_Avoid_: comment chain, discussion, comment

#### Addressed Finding

A new finding that matches a prior Review Thread the bot itself posted. That thread is either marked resolved, or has a reply the agent judges as fixing it. Dropped from the draft; never posted again.\
_Avoid_: resolved finding, fixed finding

#### Open Finding

A new finding that matches a prior Review Thread the bot itself posted, but that thread is neither resolved nor addressed by a reply. Dropped from the draft to avoid duplicating the bot's own still-open comment. Listed separately from Addressed Findings in the step-7 draft, so the user can see it was intentionally skipped, not missed.\
_Avoid_: duplicate finding, repeat finding

#### New Finding

A finding with no matching prior Review Thread from the bot. Drafted as a fresh inline comment, same as today's behavior.\
_Avoid_: fresh finding
