# Agent instructions

## Conventions

Commit message and CI conventions shared across all `dnd-mapp` repositories are documented in [GitHub Repository Conventions](https://github.com/dnd-mapp/wiki/blob/main/pages/development-conventions/github.md).

Pull request conventions are documented in [Creating a Pull Request](https://github.com/dnd-mapp/wiki/blob/main/pages/development-conventions/creating-a-pull-request.md).

## Commit conventions

Run the `commit` skill ([skills/commit/SKILL.md](skills/commit/SKILL.md)) to commit changes.

## Pull requests

This repo uses GitHub for pull requests. For configuration, see [docs/agents/pull-requests.md](docs/agents/pull-requests.md).

## Wayfinding

Wayfinder maps and tickets are tracked as local Markdown files. For configuration, see [docs/agents/wayfinder.md](docs/agents/wayfinder.md).

## Review comments

Run the `review-comments` skill ([skills/review-comments/SKILL.md](skills/review-comments/SKILL.md)) to draft and post PR review comments. For configuration, see [docs/agents/review-comments.md](docs/agents/review-comments.md).

## Address comments

Run the `address-comments` skill ([skills/address-comments/SKILL.md](skills/address-comments/SKILL.md)) to work through unresolved review threads, unaddressed general PR comments, and unaddressed review summaries with code changes, replies, and thread resolutions. It has no configuration file. The PR author runs it on their own PR, so replies and thread resolutions post as the active `gh` account rather than a configured bot.
