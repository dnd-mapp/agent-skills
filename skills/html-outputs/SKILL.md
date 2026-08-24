---
name: html-outputs
description: Decide whether to produce HTML instead of Markdown, or build a small interactive HTML tool, for a spec, plan, report, review, or other rich output. Use when generating a substantial written deliverable meant to be shared as a link, or one with tables, diagrams, or comparisons that don't fit plain Markdown. Also use when a tunable interactive tool, such as a custom editor or prototype, would serve the task better than a static document.
---

# HTML Outputs

Markdown is compact and easy to edit, but it becomes hard to read and share once an output grows past roughly a hundred lines. Reach for HTML when one of the reasons below applies, and default to Markdown for shorter, simpler outputs.

## Why HTML helps

- **More expressive.** Real tables, CSS-driven layout and color, SVG diagrams, embedded code with syntax highlighting, and small JavaScript-driven interactions, so nothing has to get flattened into a bullet list or ASCII art.
- **Easier to read at scale.** A long Markdown file tends to go unread; an HTML document can use tabs and visual hierarchy to stay navigable as it grows, and adapt to different screen sizes.
- **Easier to share.** A Markdown file needs to be opened in an editor or attached to a message. An HTML file can be shared as a link and opened directly in a browser, which raises the odds someone actually reads it.
- **Supports two-way interaction.** Sliders, toggles, or other controls to tune parameters or explore options. These often pair with a button that copies the result back out as text or JSON to feed into a follow-up prompt.
- **Plays well with rich context gathering.** When you pull in files, connected tools, browser context, or git history, you often have more material than plain text can convey. HTML gives you a natural place to turn it into diagrams and structured summaries.

## When to reach for HTML

- **Specs, planning, and exploration:** side-by-side comparisons of different approaches, mockups, and implementation plans meant to be read back later, including as reference material during verification.
- **Code review and understanding:** rendering diffs with inline annotations, severity color-coding, and flowcharts to explain unfamiliar logic in a change.
- **Design and prototypes:** sketching a UI or interaction, including animations or tunable parameters, before it gets ported into the real implementation language.
- **Reports, research, and learning:** explainers, status reports, and incident write-ups that synthesize several sources and benefit from diagrams.
- **Custom editing interfaces:** a one-off, purpose-built editor for a specific task, such as triaging a backlog or editing structured config. It typically ends in a "copy as JSON" or "copy as prompt" button so the result can be pasted back into the conversation.

## When Markdown is still fine

Short, simple outputs, especially ones under about a hundred lines with no need for tables, diagrams, or interactivity, are still well served by Markdown. Use judgment: the goal is readability and usefulness, not reaching for HTML by default.
