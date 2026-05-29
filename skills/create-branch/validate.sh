#!/usr/bin/env bash

# Validates a branch name against the rules in SKILL.md.
#
# Usage:
#   ./validate.sh "<branch name>"
#   echo "<branch name>" | ./validate.sh
#
# Exit 0: name is valid — stdout: "OK"
# Exit 1: violations found — stderr: one VIOLATION line per rule broken,
#         stdout: best-effort mechanically fixed name (lowercase, replace
#         spaces/underscores with hyphens, strip invalid chars, truncate
#         slug to 40 chars). Type violations require skill judgment.

set -uo pipefail

VALID_TYPES="build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test"
MAX_SLUG=40

# ---------------------------------------------------------------------------
# Read input
# ---------------------------------------------------------------------------
if [[ $# -gt 0 ]]; then
  branch="$1"
else
  branch="$(cat)"
fi

violations=()
fixed="$branch"

# ---------------------------------------------------------------------------
# 1. Overall format: type/[issue-]slug  (issue is digits, slug is kebab-case)
# ---------------------------------------------------------------------------
if [[ ! "$branch" =~ ^([^/]+)/(.+)$ ]]; then
  violations+=("Branch name must contain exactly one '/' separating type from slug (got '${branch}')")

  printf '%s\n' "${violations[@]/#/VIOLATION: }" >&2
  echo "$fixed"
  exit 1
fi

type_part="${BASH_REMATCH[1]}"
rest="${BASH_REMATCH[2]}"   # everything after the slash: [issue-]slug

# ---------------------------------------------------------------------------
# 2. Type must be a known Conventional Commits type
# ---------------------------------------------------------------------------
if [[ ! "$type_part" =~ ^($VALID_TYPES)$ ]]; then
  violations+=("Unknown type '${type_part}'. Allowed types: build, chore, ci, docs, feat, fix, perf, refactor, revert, style, test")
fi

# ---------------------------------------------------------------------------
# 3. Extract optional issue number and slug
#    Accepted shapes: "42-my-slug"  "my-slug"
# ---------------------------------------------------------------------------
issue_part=""
slug_part="$rest"

if [[ "$rest" =~ ^([0-9]+)-(.+)$ ]]; then
  issue_part="${BASH_REMATCH[1]}"
  slug_part="${BASH_REMATCH[2]}"
fi

# ---------------------------------------------------------------------------
# 4. Slug must be kebab-case (lowercase letters, digits, hyphens only)
#    Auto-fix: lowercase, replace spaces/underscores with hyphens,
#              strip remaining invalid chars
# ---------------------------------------------------------------------------
fixed_slug="$slug_part"

if [[ "$slug_part" =~ [A-Z] ]]; then
  violations+=("Slug must be lowercase (got uppercase letters in '${slug_part}')")
  fixed_slug="${fixed_slug,,}"
fi

if [[ "$slug_part" =~ [[:space:]] ]]; then
  violations+=("Slug must not contain spaces — replace with hyphens")
  fixed_slug="${fixed_slug//[[:space:]]/-}"
fi

if [[ "$slug_part" =~ _ ]]; then
  violations+=("Slug must not contain underscores — use hyphens instead")
  fixed_slug="${fixed_slug//_/-}"
fi

# Strip any character that is not a lowercase letter, digit, or hyphen
stripped_slug="${fixed_slug//[^a-z0-9-]/}"

if [[ "$stripped_slug" != "$fixed_slug" ]]; then
  violations+=("Slug contains invalid characters — only lowercase letters, digits, and hyphens are allowed")
  fixed_slug="$stripped_slug"
fi

# Collapse multiple consecutive hyphens
fixed_slug="${fixed_slug//--/-}"
# Strip leading/trailing hyphens
fixed_slug="${fixed_slug##-}"
fixed_slug="${fixed_slug%%-}"

# ---------------------------------------------------------------------------
# 5. Slug length ≤ 40 characters
# ---------------------------------------------------------------------------
slug_len=${#fixed_slug}

if [[ $slug_len -gt $MAX_SLUG ]]; then
  violations+=("Slug is ${slug_len} characters — max is ${MAX_SLUG}. Rewrite to be more concise while preserving intent.")
  fixed_slug="${fixed_slug:0:$MAX_SLUG}"
  # Trim trailing hyphen left by truncation
  fixed_slug="${fixed_slug%%-}"
fi

# ---------------------------------------------------------------------------
# Rebuild the fixed branch name
# ---------------------------------------------------------------------------
if [[ -n "$issue_part" ]]; then
  fixed="${type_part}/${issue_part}-${fixed_slug}"
else
  fixed="${type_part}/${fixed_slug}"
fi

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------
if [[ ${#violations[@]} -eq 0 ]]; then
  echo "OK"
  exit 0
fi

for v in "${violations[@]}"; do
  echo "VIOLATION: $v" >&2
done

echo "$fixed"
exit 1
