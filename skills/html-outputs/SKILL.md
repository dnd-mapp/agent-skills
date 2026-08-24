---
name: html-outputs
description: Decide whether to produce a spec, plan, report, review, or other rich output as HTML instead of Markdown, or as a small interactive tool instead of a static document. Use it when a deliverable is substantial enough to share as a link, or needs tables, diagrams, or comparisons Markdown renders poorly. Reach for the interactive form when a tunable, hands-on artifact would serve the task better than either static format.
---

# HTML Outputs

Markdown is compact and easy to edit, but it becomes hard to read and share once an output grows past roughly a hundred lines. Reach for HTML when one of the reasons below applies, and default to Markdown for shorter, simpler outputs.

## Why HTML helps

- **More expressive.** Real tables, CSS-driven layout and color, SVG diagrams, embedded code with syntax highlighting, and small JavaScript-driven interactions, so nothing has to get flattened into a bullet list or ASCII art.
- **Easier to read at scale.** A long Markdown file tends to go unread; an HTML document can use tabs and visual hierarchy to stay navigable as it grows, and adapt to different screen sizes.
- **Easier to share.** A Markdown file needs to be opened in an editor or attached to a message. An HTML file can be shared as a link and opened directly in a browser, which raises the odds someone actually reads it.
- **Supports two-way interaction.** Sliders, toggles, or other controls to tune parameters or explore options. These often pair with a button that copies the result back out as text or JSON to feed into a follow-up prompt.

## When to reach for HTML

- **Specs, planning, and exploration:** side-by-side comparisons of different approaches, mockups, and implementation plans meant to be read back later, including as reference material during verification.
- **Code review and understanding:** rendering diffs with inline annotations, severity color-coding, and flowcharts to explain unfamiliar logic in a change.
- **Design and prototypes:** sketching a UI or interaction, including animations or tunable parameters, before it gets ported into the real implementation language.
- **Reports, research, and learning:** explainers, status reports, and incident write-ups that synthesize several sources and benefit from diagrams.
- **Custom editing interfaces:** a one-off, purpose-built editor for a specific task, such as triaging a backlog or editing structured config, ending in the copy-out button described above.

## When Markdown is still fine

Short, simple outputs below that same threshold, with no need for tables, diagrams, or interactivity, are still well served by Markdown. Use judgment, weighing readability and usefulness over defaulting to HTML.

## Before finalizing

Whichever format you land on, run the `writing-style` skill over the prose before presenting it as finished.
