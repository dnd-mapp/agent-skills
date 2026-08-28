# Review comment dedup matches on thread state and reply judgment, not per-comment diff tracking

When `review-comments` re-runs on a PR, it needs to know whether a finding it already raised is worth raising again. GitHub review threads carry two independent, low-cost signals: resolved status and reply content. A third option would diff the flagged code against what it looked like when the comment was first posted. That would require tracking the original commit per comment, and inferring "still the same problem" from code shape alone.

We combine the two thread-native signals instead: a thread counts as addressed if it's resolved, or if it has a reply the agent judges as fixing it. We also suppress findings that repeat a thread that's neither resolved nor addressed (an Open Finding), not just addressed ones. Re-posting a still-open comment verbatim every run is the same noise problem as re-posting an addressed one. Where a match is ambiguous, we default to not suppressing: post again rather than the reverse. A missed regression is a correctness bug in the review. An occasional duplicate is just a two-second dismissal during approval.

The same check also runs against the account's earlier top-level review bodies and general PR comments, so a point it once made only in a review summary still dedupes. Those sources carry no resolved bit, so the addressed signal there is narrower: the current diff or a later author reply has to visibly answer the point. The skill's step 7 carries the operative rule for all three sources.

## Considered Options

- **Resolved status only.** Rejected: cheap and explicit, but a silent fix without a resolve-click would still get re-flagged. A resolved-but-not-actually-fixed thread would also silently suppress a real issue.
- **Diffing the code at the flagged location against its state when the old comment was posted.** Rejected: requires tracking the original commit per comment, and inferring sameness from code shape. That's strictly more machinery than reading two signals GitHub already tracks per thread. Reading the *current* diff to judge whether a sourceless point (one made only in a review body or PR comment, with no thread and no resolved bit) has since been answered is a different thing: the same reading-comprehension judgment applied to the live diff, with no per-comment history to track.
- **Suppress only Addressed Findings, re-flag Open ones every run.** Rejected: an Open Finding matching an old unresolved thread is functionally a duplicate of the bot's own still-open comment. Leaving it in scope for re-posting recreates the noise this feature exists to remove.
- **Default ambiguous matches to suppress.** Rejected: an unnoticed suppressed finding is a silent regression in review quality, judged worse than an occasional duplicate the user dismisses during the approval step.

## Consequences

Matching depends on the agent's reading comprehension of thread content rather than a mechanical rule, so its accuracy is only as good as that judgment call. This is deliberate and consistent with how the skill already resolves findings to file/line by reading comprehension rather than mechanical parsing. But it means a future reader shouldn't expect matching to be deterministic or independently testable without re-running the agent.

Top-level review bodies and general PR comments carry no resolved bit, so for a point made only in one of those the dedup has no explicit signal to fall back on and leans entirely on reading the current diff and any later author reply. The ambiguous-match default (post again) therefore does more of the work for those sources than for threads.
