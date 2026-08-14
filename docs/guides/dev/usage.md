# Usage

```bash
pnpm format        # Format all files with Prettier
pnpm format-check  # Check formatting without writing changes
pnpm lint-md       # Lint Markdown files with markdownlint-cli2
```

Husky and lint-staged run Prettier and markdownlint on staged files before each commit. GitHub Actions runs the same checks on every pull request and on pushes to `main` (see [`.github/workflows/`](../../../.github/workflows/)), and validates commit messages against [Conventional Commits](https://www.conventionalcommits.org/) via commitlint.
