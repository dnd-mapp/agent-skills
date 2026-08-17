# dnd-mapp/agent-skills

Claude Code Agent Skills and Subagent definitions for the `dnd-mapp` organization. Skills are written to the open Agent Skills standard and are portable beyond Claude Code; subagents target Claude Code's own format, since no portable standard exists for those yet.

## Available skills

| Skill                              | Description                                                                                                                                                 |
|------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [`branch`](skills/branch/SKILL.md) | Create a git branch named for the work ahead, following this org's branch naming convention.                                                                |
| [`commit`](skills/commit/SKILL.md) | Commit the working tree, grouped into separate commits by intent with Conventional Commits messages, reviewed with you before anything is applied.          |
| [`pr`](skills/pr/SKILL.md)         | Draft a pull request for the current branch (title, description, related issues, and checklist derived from the diff), reviewed with you before opening it. |

## Using skills from this repo

Skills published here are installable either:

- as the `dnd-mapp` Claude Code plugin, or
- via the [`skills`](https://www.npmjs.com/package/skills) package: `pnpm dlx skills add dnd-mapp/agent-skills`

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guides.

## License

[MIT](LICENSE)
