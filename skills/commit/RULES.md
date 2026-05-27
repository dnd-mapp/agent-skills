# Conventional Commits Rules

## Format

```text
type(scope)!: Subject

Body

Footer
```

## Types

`build` `chore` `ci` `docs` `feat` `fix` `perf` `refactor` `revert` `style` `test`

## Scope

- One scope per commit — never more than one.
- Infer from the repo structure (top-level directories, package names) combined
  with the specific paths touched by the changes in that group.

## Subject line

- Imperative, present tense ("Add" not "Added" or "Adds")
- Capitalized first letter
- No trailing period
- **Strictly ≤ 50 characters** — rewrite internally until it fits; never present an over-length subject to the user

## Body

- Optional — include only when the motivation is non-obvious
- Blank line between subject and body
- Wrap each line at **72 characters**

## Footer

- Blank line between body (or subject, if no body) and footer
- Trailers appear one per line

### Issue references

1. Parse the current branch name for an issue number (e.g. `feat/123-add-login` → `#123`).
2. If no number is found, ask the user whether to add a reference.
3. Choose the trailer based on the commit type:

   | Commit type    | Trailer      |
   |:---------------|:-------------|
   | `fix`          | `Fixes #N`   |
   | `feat`         | `Closes #N`  |
   | anything else  | `Refs #N`    |

### Breaking changes

- Analyze the diff for: removed exports, changed function signatures, renamed APIs, dropped parameters, changed return types.
- If a breaking change is detected, ask the user to confirm before flagging.
- Confirmed breaking changes:
  - Add `!` after the scope: `feat(auth)!: ...`
  - Add trailer: `BREAKING CHANGE: <description>`

## Example

```text
feat(auth): Add OAuth2 login flow

Replaces the legacy session-cookie approach to meet the new
compliance requirements around token storage.

Closes #42
```

```text
fix(api)!: Remove deprecated v1 endpoints

BREAKING CHANGE: /api/v1/* routes are no longer available.
Migrate to /api/v2/*.

Fixes #87
```
