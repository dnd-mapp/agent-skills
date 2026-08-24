---
name: html-outputs
description: Decide whether to produce HTML instead of Markdown for a spec, plan, report, review, or other rich output. Use when generating a substantial written deliverable, especially one with tables, diagrams, comparisons, or content meant to be shared as a link rather than opened in an editor.
---

# HTML Outputs

Markdown is compact and easy to edit. But it becomes hard to read and share once an output grows past roughly a hundred lines, or needs to convey more than plain text and lists. Reach for HTML instead whenever the output would benefit from structure, visuals, or shareability, and default to Markdown for shorter, simpler ones.

## Why HTML helps

- **More expressive.** Real tables, CSS-driven layout and color, SVG diagrams, embedded code with syntax highlighting, and small JavaScript-driven interactions, so nothing has to get flattened into a bullet list or ASCII art.
- **Easier to read at scale.** A long Markdown file tends to go unread; an HTML document can use tabs and visual hierarchy to stay navigable as it grows, and adapt to different screen sizes.
- **Easier to share.** A Markdown file needs to be opened in an editor or attached to a message. An HTML file can be shared as a link and opened directly in a browser, which raises the odds someone actually reads it.
- **Supports two-way interaction.** Sliders, toggles, or other controls to tune parameters or explore options, often paired with a button that copies the result back out as text or JSON to feed into a follow-up prompt.
- **Plays well with rich context gathering.** When you pull in files, connected tools, browser context, or git history, HTML gives you a natural place to turn that material into diagrams and structured summaries rather than plain lists of text.

## When to reach for HTML

- **Specs, planning, and exploration:** side-by-side comparisons of different approaches, mockups, and implementation plans meant to be read back later, including as reference material during verification.
- **Code review and understanding:** rendering diffs with inline annotations, severity color-coding, and flowcharts to explain unfamiliar logic in a change.
- **Design and prototypes:** sketching a UI or interaction, including animations or tunable parameters, before it gets ported into the real implementation language.
- **Reports, research, and learning:** explainers, status reports, and incident write-ups that synthesize several sources and benefit from diagrams.
- **Custom editing interfaces:** a one-off, purpose-built editor for a specific task, such as triaging a backlog or editing structured config, typically ending in a "copy as JSON" or "copy as prompt" button so the result can be pasted back into the conversation.

## When Markdown is still fine

Short, simple outputs, especially ones under about a hundred lines with no need for tables, diagrams, or interactivity, are still well served by Markdown. Use judgment: the goal is readability and usefulness, not reaching for HTML by default.
