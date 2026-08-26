# Contributing

Development setup and conventions for this repo.

## Prerequisites

- [Node.js](https://nodejs.org/) 24.18.0
- [pnpm](https://pnpm.io/) 11.21.0

Both versions are pinned in `package.json`'s `devEngines` field. Install [mise](https://mise.jdx.dev/) (recommended) and run `mise install` to pick up matching versions automatically.

## Setup

Install dependencies and set up the Husky git hooks:

```bash
pnpm install
```

## Adding a skill

New skills live at `skills/<name>/SKILL.md`. Frontmatter needs a `name` and `description`; add `disable-model-invocation: true` if the skill should only run when explicitly invoked (see [`skills/ship/SKILL.md`](skills/ship/SKILL.md) for a working example). Otherwise, write the description so an agent can tell when to invoke it on its own: state what the skill does, then when to use it (see [`skills/commit/SKILL.md`](skills/commit/SKILL.md)). Keep terminology consistent with [CONTEXT.md](CONTEXT.md) ("Agent Skill", not "skill file" or "plugin"). Add the new skill to the [Available skills](README.md#available-skills) table in `README.md` so it's discoverable.

If a skill needs per-integration mechanics (a different tracker, provider, or backend per repo), bundle one file per integration under `skills/<name>/operations/<integration>.md` rather than growing a single mega-doc; the skill's `SKILL.md` stays integration-agnostic and calls out to the file selected by the repo's config (see [`skills/file-ticket/SKILL.md`](skills/file-ticket/SKILL.md) and [`skills/file-ticket/operations/github.md`](skills/file-ticket/operations/github.md)). If the skill also needs per-repo bootstrap config (target repo, credentials, defaults), keep that in `docs/agents/<name>.md`, separate from the operations files.

If you're using Claude Code, the `writing-for-agents` skill covers conventions for authoring `SKILL.md`, `AGENTS.md`, and `CLAUDE.md` files.

## Style and validation

- [Editor setup](docs/guides/dev/editor-setup.md): configuring Prettier to run in VS Code or WebStorm.
- [Usage](docs/guides/dev/usage.md): available `pnpm` scripts, and what runs in CI (formatting, Markdown lint, and commit message checks).

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/), checked by commitlint. If you're using Claude Code, the `commit` skill ([`skills/commit/SKILL.md`](skills/commit/SKILL.md)) groups changes by intent and drafts messages that follow this repo's conventions.

## Reporting bugs and requesting features

Use this repo's [GitHub Issues](https://github.com/dnd-mapp/agent-skills/issues).

## Opening a pull request

See [Creating a Pull Request](https://wiki.dndmapp.nl.eu.org/development-conventions/creating-a-pull-request) for how to open a pull request in any `dnd-mapp` repository.
