---
name: writing-style
description: Review prose for em dashes and overlong sentences before finalizing it. Use when writing any output meant to be reused, not just files saved to disk, including PR or issue text posted via `gh`. Does not apply to ordinary conversational replies.
---

# Writing Style

A review pass over prose you just wrote, done as a last step before presenting it as finished. Prose posted through a CLI like `gh` (PR and issue titles, bodies, comments) gets this as its only check, since that path has no normal edit-and-review flow of its own. Applies to HTML output as well as Markdown.

## 1. Remove em dashes

The em dash character is not allowed anywhere in the output. Replace each one with whichever fits the sentence best:

- A period, splitting the sentence in two.
- A comma, if the clauses are short and closely related.
- A colon, if what follows explains or lists what came before.
- Parentheses, for a true aside.
- A connecting word such as "and," "but," "so," or "because," if that reads more naturally.

Don't default to a hyphen or semicolon; pick whichever keeps the sentence clearest.

## 2. Shorten long sentences

Flag any sentence that's hard to follow in one read, especially ones with several comma-separated clauses or that run past roughly 25-30 words. Rewrite by:

- Splitting into two or more sentences.
- Converting a list-like sentence into an actual bulleted or numbered list.
- Cutting subordinate clauses that just restate something already said.

## 3. Re-read before finishing

Do this as a last pass after drafting, not while drafting. Write the content first, then re-read it once, checking specifically for em dashes and long sentences, and fix anything found before presenting the result as done.
