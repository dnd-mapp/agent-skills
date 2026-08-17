# Wayfinder

## Tracker

Local Markdown files: no external issue tracker is configured for this repo.

## Layout

- Map: `docs/wayfinder/<slug>/MAP.md`
- Tickets: `docs/wayfinder/<slug>/tickets/<ticket-slug>.md`

## Wayfinding operations

**Map**: the map body lives directly in `MAP.md`, following the wayfinder skill's map-body template (Destination / Notes / Decisions so far / Not yet specified / Out of scope).

**Tickets**: each ticket is a file under `tickets/`, with YAML frontmatter:

```yaml
---
title: <ticket title>
type: research | prototype | grilling | task
status: open | closed
assignee: <gh username, or empty>
blocked_by: [<ticket-slug>, ...]
---
```

followed by the `## Question` body. On resolution, append a `## Resolution` section with the answer and set `status: closed`.

**Claiming**: set `assignee` to the driving dev's GitHub username before starting work on a ticket. An open ticket with an empty `assignee` is unclaimed.

**Blocking**: `blocked_by` lists other ticket slugs (within the same map) that must be `closed` first. Local Markdown has no native dependency graph, so this list is the source of truth.

**Frontier query**: tickets where `status: open`, `assignee` is empty, and every slug in `blocked_by` points to a ticket with `status: closed`.
