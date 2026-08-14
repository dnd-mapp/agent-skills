# dnd-mapp/agent-skills

Claude Code Agent Skills and Subagent definitions for the `dnd-mapp` organization. Skills are written to the open Agent Skills standard and are portable beyond Claude Code; subagents target Claude Code's own format, since no portable standard exists for those yet.

## Prerequisites

- [mise](https://mise.jdx.dev/) (recommended): manages the Node.js and pnpm versions this repo pins in `package.json`'s `devEngines` field. Run `mise install` after installing it to pick up matching versions automatically.

## Available skills

| Skill                              | Description                                                                                                                                        |
|------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| [`commit`](skills/commit/SKILL.md) | Commit the working tree, grouped into separate commits by intent with Conventional Commits messages, reviewed with you before anything is applied. |

## Using skills from this repo

Skills published here are installable either:

- as a Claude Code plugin, or
- via the [`skills`](https://www.npmjs.com/package/skills) package: `npx skills add dnd-mapp/agent-skills`

## Guides

- [Editor setup](docs/guides/dev/editor-setup.md): configuring Prettier to run in VS Code or WebStorm.
- [Usage](docs/guides/dev/usage.md): available `pnpm` scripts, and what runs in CI.

## Contributing

Install dependencies and set up the Husky git hooks:

```bash
pnpm install
```

See [Creating a Pull Request](https://wiki.dndmapp.nl.eu.org/development-conventions/creating-a-pull-request) for how to open a pull request in any `dnd-mapp` repository.

## License

[MIT](LICENSE)
