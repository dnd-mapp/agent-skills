# agent-skills

Reusable agent skills for AI-assisted development workflows.

## Requirements

- Node.js ≥ 18

## Install

```sh
# Install all skills (auto-detects your agent)
npx skills add dnd-mapp/agent-skills

# Install globally (available across all projects)
npx skills add dnd-mapp/agent-skills -g

# Install a specific skill
npx skills add dnd-mapp/agent-skills --skill commit
```

For more options, supported agents, and uninstall/update instructions, see the [`skills`](https://npmx.dev/package/skills) package.

## Skills

| Skill                                                              | Description                                                          |
|:-------------------------------------------------------------------|:---------------------------------------------------------------------|
| [commit](skills/commit/SKILL.md)                                   | Groups working-tree changes into Conventional Commits                |
| [create-branch](skills/create-branch/SKILL.md)                     | Infers a branch name from changes and creates it                     |
| [configure-issue-tracker](skills/configure-issue-tracker/SKILL.md) | Configures issue tracking — local, GitHub Issues, or GitHub Projects |
