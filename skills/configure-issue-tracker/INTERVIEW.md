# Interview Structure

The interview is **adaptive grouped sequential**: questions are grouped by topic, and sub-questions are only asked when the user wants to override a default. At the start of each group, surface all defaults and ask "does this work, or do you want to change anything?"

After the interview completes, present a full review of all decisions and provisioning actions before writing anything — see **Review & Approve** below.

---

## Group 0 — Backend & Setup

### Tracker Backend detection

Auto-detect from `git remote get-url origin`:

- GitHub URL detected → default: `github-issues`
- No remote or non-GitHub remote → default: `local`

Present the detected default and ask the user to confirm or change it.

**Options:** `local` | `github-issues` | `github-issues-projects`

### Routing

After Group 0 completes, continue with the appropriate files in order:

1. **If GitHub backend:** run [INTERVIEW-GITHUB.md](INTERVIEW-GITHUB.md) — auth, org detection, repo config
2. **Backend-specific interview:**
   - `local` → [INTERVIEW-LOCAL.md](INTERVIEW-LOCAL.md)
   - `github-issues` → [INTERVIEW-GITHUB-ISSUES.md](INTERVIEW-GITHUB-ISSUES.md)
   - `github-issues-projects` → [INTERVIEW-GITHUB-ISSUES-PROJECTS.md](INTERVIEW-GITHUB-ISSUES-PROJECTS.md)
3. **All backends:** run [INTERVIEW-SHARED.md](INTERVIEW-SHARED.md) — Issue Types, hierarchy, statuses, body templates

---

## Review & Approve

Before writing any files or calling any GitHub API, present a full summary:

- Tracker Backend selected
- All Issue Types and their configuration
- For GitHub backends: every GitHub action that will be performed — labels to create, fields to create, Project to create (if applicable), org-level Issue Types to create (if applicable)
- Local files that will be written (`docs/agents/`, `CLAUDE.md`, `AGENTS.md`)

Ask for explicit approval. If the user wants to change anything, return to the relevant interview section. Only proceed after approval is given.
