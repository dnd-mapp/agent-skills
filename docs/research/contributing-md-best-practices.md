# CONTRIBUTING.md: common content and best practices

Research notes backing the rewrite of the repo's [`CONTRIBUTING.md`](../../CONTRIBUTING.md). No existing convention for research notes was found in this repo (only `docs/agents/` and `docs/guides/dev/` existed), so this lives under `docs/research/`.

## What GitHub's own docs say

Source: [Setting guidelines for repository contributors](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/setting-guidelines-for-repository-contributors) (docs.github.com)

- Recommended content: "steps for creating good issues or pull requests," "links to external documentation, mailing lists, or a code of conduct," and "community and behavioral expectations."
- File location: GitHub looks for the file in three places, in priority order: `.github/`, the repo root, then `docs/`. All three are recognized as "community health files."
- Surfacing: once present, GitHub links to it automatically when someone opens a pull request or creates an issue, adds a "Contributing" tab to the repo overview alongside README and Code of Conduct, and shows a "Contributing" link in the sidebar.
- Rationale given: it helps contributors "submit well-formed pull requests and open useful issues," saving maintainer time on rejected submissions.

## What opensource.guide (published by GitHub) says

Source: [Starting a Project](https://opensource.guide/starting-a-project/) (opensource.guide)

- Recommends covering: how to file bug reports (via issue/PR templates if present), how to suggest new features, environment setup and test-running instructions, the types of contributions being sought, the project's roadmap/vision, and how contributors should (or shouldn't) get in touch.
- Tone: recommends a warm, welcoming opening and explicitly suggesting non-code ways to contribute (docs, a website, etc.) to make newcomers feel welcome; cites Active Admin's CONTRIBUTING.md opening as an example ("It's people like you that make Active Admin such a great tool").
- Progressive scope: early-stage projects can keep it to bug-reporting steps and technical requirements; add an FAQ as repetitive questions accumulate.
- Discoverability: link the CONTRIBUTING file from the README so GitHub's automatic surfacing (see above) kicks in.

Source: [Best Practices for Maintainers](https://opensource.guide/best-practices/) (opensource.guide)

- Recommends explaining how a contribution is reviewed and accepted (test requirements, templates used), what types of contributions will be accepted, and, for volunteer-run projects, setting expectations on response time and maintainer bandwidth (its examples: "expect a response within 7 days," "we only spend about 5 hours/week on this").
- Explicitly calls out keeping docs current: "delete your outdated documentation or indicate it is outdated so contributors know updates are welcome."
- Cites Jekyll, CocoaPods, and Homebrew as projects with well-documented contribution ground rules worth modeling.

## What a real, actively-maintained CONTRIBUTING.md contains

Source: [pnpm/pnpm CONTRIBUTING.md](https://github.com/pnpm/pnpm/blob/main/CONTRIBUTING.md) (fetched directly, not a summary of it): chosen because this repo already depends on pnpm's own tooling conventions.

Section order, as written: **Setting Up the Environment** → **Working with Git Worktrees** → **Running Tests** → **Submitting a Pull Request** (branch naming, changesets, review flow, a note on AI-assisted contributions, post-merge cleanup) → **Coding Style Guidelines** (points at their Standard Style formatter) → **Commit Message Guidelines** (Conventional-Commits-style type/scope/subject/body/footer spec).

Takeaway: real-world CONTRIBUTING.md files are almost entirely mechanical/procedural (setup, validate, submit), not prose about project philosophy. The "warm welcome" framing from opensource.guide is common in community-driven OSS projects seeking outside contributors, but far less present in tooling-focused or single-org repos.

## How these findings shaped the rewrite

This repo (`dnd-mapp/agent-skills`) is small, single-org, has no test suite, no issue/PR templates of its own (PR template is inherited from the org-wide `dnd-mapp/.github` repo, confirmed via `docs/agents/pull-requests.md`), and no `CODE_OF_CONDUCT.md` at the repo or org level (checked `dnd-mapp/.github`'s file listing directly: not present). So most of opensource.guide's "welcoming OSS project" framing (roadmap/vision, response-time SLAs, non-code contribution pitches, FAQ) doesn't apply and would be invented content; it was left out.

What did apply and drove concrete changes to `CONTRIBUTING.md`:

- **Root location is correct**: it's GitHub's #2 priority location and is standard for public-facing repos; no reason to move it into `.github/` or `docs/`.
- **Linked from README**: already done in the prior split (`README.md`'s "Contributing" section points at `CONTRIBUTING.md`), which is what makes GitHub's automatic PR/issue surfacing meaningful.
- **Mechanical, setup-validate-submit ordering** (matching the pnpm example): the existing Prerequisites, Setup, Guides, Opening a pull request order already follows this shape; kept it.
- **"How a contribution is validated" should be explicit** (GitHub docs and opensource.guide's Best-Practices page both call this out): the guides section was retitled from "Guides" to "Style and validation" to name what it actually documents: Prettier/markdownlint formatting and the CI checks (including commitlint against Conventional Commits) described in `docs/guides/dev/usage.md`.
- **No invented sections**: no test-running section (no test suite exists), no code-of-conduct link (none exists), no response-time promises (not an established policy here).

## PR-conventions URL: not actually a discrepancy

`CONTRIBUTING.md`'s "Opening a pull request" section links to `https://wiki.dndmapp.nl.eu.org/development-conventions/creating-a-pull-request`, while `AGENTS.md` links to `https://github.com/dnd-mapp/wiki/blob/main/pages/development-conventions/creating-a-pull-request.md`. These looked like they might be two different sources of truth, but they're the same content via two access paths:

- `dnd-mapp/wiki` is, per its own README ([raw.githubusercontent.com/dnd-mapp/wiki/main/README.md](https://raw.githubusercontent.com/dnd-mapp/wiki/main/README.md)), "Git storage backend for the D&D Mapp Wiki.js instance, live at [wiki.dndmapp.nl.eu.org](https://wiki.dndmapp.nl.eu.org)"; a `publish-live` GitHub Actions workflow keeps the hosted site in sync with `pages/` on `main`.
- The file exists at `pages/development-conventions/creating-a-pull-request.md` in that repo (confirmed via `gh api repos/dnd-mapp/wiki/contents/pages/development-conventions`), and the hosted URL returns HTTP 200 (confirmed via `curl`).

Left `CONTRIBUTING.md`'s link as the hosted Wiki.js URL (more appropriate for human readers than a raw GitHub blob link), and made no change here.
