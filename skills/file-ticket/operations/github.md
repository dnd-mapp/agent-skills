# GitHub operations

GitHub-specific mechanics for each operation [../SKILL.md](../SKILL.md) invokes by name. Selected whenever a repo's [docs/agents/file-ticket.md](../../../docs/agents/file-ticket.md) sets `Tracker` to `github`.

## `fetch-template(repo) -> Template Candidate[]`

Returns 0 or more `{name, about, raw content}` entries, uniformly whether the source is a legacy Markdown template, a Markdown chooser entry, or a YAML issue form. Always fetched via the Contents API, never via `gh issue create --template` or the GraphQL `issueTemplates` field, both of which silently drop YAML forms.

1. List `.github/ISSUE_TEMPLATE/`:

   ```bash
   gh api repos/<owner>/<repo>/contents/.github/ISSUE_TEMPLATE
   ```

   If that path doesn't exist, fall back to checking for a single `ISSUE_TEMPLATE.md` at the repo root, then `.github/`, then `docs/` (GitHub's own three-location priority for the legacy single-file form).

2. For each entry other than `config.yml` (metadata, not a template, so skip it), fetch its raw content:

   ```bash
   gh api -H "Accept: application/vnd.github.raw+json" repos/<owner>/<repo>/contents/<path>
   ```

3. Branch on extension to build each `Template Candidate`:
   - **`.md`**: parse the YAML front matter for `name` and `about`. `name`/`about` become the candidate's fields; the full raw file (front matter and body together) is the candidate's raw content.
   - **`.yml` / `.yaml`**: parse the top-level `name` and `description` keys (`description` fills the candidate's `about`). The full raw YAML is the candidate's raw content. `SKILL.md` reads it directly when drafting a body from it; this operation does no field-by-field parsing of the `body` array.
   - **Legacy single `ISSUE_TEMPLATE.md`** (no chooser directory): one candidate, `name`/`about` both empty, raw content the whole file.

## `search-duplicates(repo, query) -> {ok: true, candidates: {number, title, url, state}[]} | {ok: false}`

```bash
gh issue list --search "<query>" --state open --limit 5 --json number,title,url,state
```

`query` is the drafted title, passed verbatim, with no manual keyword extraction. GitHub's default search scope (no `in:` qualifier) already covers title, body, and comments with its own relevance ranking. Returns `{ok: false}` on any command failure (rate limit, transient API error, etc.); a real zero-result search returns `{ok: true, candidates: []}`.

## `create-ticket(repo, title, body, labels) -> {number, url}`

```bash
gh issue create --repo <repo> --title "<title>" --body-file - --label "<label1>,<label2>,..." <<'EOF'
<body>
EOF
```

Never pass `--template`: it cannot resolve a YAML form (excluded from the GraphQL field it relies on) and is hard-mutually-exclusive with a supplied `--body`/`--body-file` even for Markdown templates. Always submit a fully-assembled title and body instead. Omit `--label` entirely when `labels` is empty.

## `resolve-target-repo(override?, default?) -> {owner, repo}`

If `override` is given, validate it:

```bash
gh repo view <override> --json owner,name
```

A repo that doesn't exist or isn't accessible surfaces as an error immediately, here, rather than failing confusingly inside `create-ticket`. Without an `override`, use `default` if given (the config's Target repo, already validated when bootstrapped) unvalidated. Without either, infer the current repo the same way:

```bash
gh repo view --json owner,name
```

## `list-labels(repo) -> string[]`

```bash
gh label list --repo <repo> --json name -q '.[].name'
```

Returns the repo's real label names for the user to pick defaults from during bootstrap. An empty list means the repo has no labels defined.
