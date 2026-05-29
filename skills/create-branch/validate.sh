#!/usr/bin/env bash
# Validates a branch name against the rules in SKILL.md.
#
# Usage:
#     ./validate.sh "<branch name>"
#     echo "<branch name>" | ./validate.sh
#
# Exit 0: name is valid — stdout: "OK"
# Exit 1: violations found — stderr: one VIOLATION line per rule broken

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

# ---------------------------------------------------------------------------
# 1. Overall format: type/[issue-]slug
# ---------------------------------------------------------------------------
if [[ ! "$branch" =~ ^([^/]+)/(.+)$ ]]; then
    echo "VIOLATION: Branch name must contain exactly one '/' separating type from slug (got '${branch}')" >&2
    exit 1
fi

type_part="${BASH_REMATCH[1]}"
rest="${BASH_REMATCH[2]}"

# ---------------------------------------------------------------------------
# 2. Type must be a known Conventional Commits type
# ---------------------------------------------------------------------------
if [[ ! "$type_part" =~ ^($VALID_TYPES)$ ]]; then
    violations+=("Unknown type '${type_part}'. Allowed types: build, chore, ci, docs, feat, fix, perf, refactor, revert, style, test")
fi

# ---------------------------------------------------------------------------
# 3. Extract optional issue number and slug
# ---------------------------------------------------------------------------
slug_part="$rest"

if [[ "$rest" =~ ^([0-9]+)-(.+)$ ]]; then
    slug_part="${BASH_REMATCH[2]}"
fi

# ---------------------------------------------------------------------------
# 4. Slug must be kebab-case (lowercase letters, digits, hyphens only)
# ---------------------------------------------------------------------------
if [[ "$slug_part" =~ [A-Z] ]]; then
    violations+=("Slug must be lowercase (got uppercase letters in '${slug_part}')")
fi

if [[ "$slug_part" =~ [[:space:]] ]]; then
    violations+=("Slug must not contain spaces — use hyphens instead")
fi

if [[ "$slug_part" =~ _ ]]; then
    violations+=("Slug must not contain underscores — use hyphens instead")
fi

if [[ "$slug_part" =~ [^a-z0-9-] ]]; then
    violations+=("Slug contains invalid characters — only lowercase letters, digits, and hyphens are allowed")
fi

# ---------------------------------------------------------------------------
# 5. Slug length ≤ 40 characters
# ---------------------------------------------------------------------------
slug_len=${#slug_part}

if [[ $slug_len -gt $MAX_SLUG ]]; then
    violations+=("Slug is ${slug_len} characters — max is ${MAX_SLUG}. Rewrite to be more concise while preserving intent.")
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

exit 1
