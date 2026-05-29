#!/usr/bin/env bash

# Validates a commit message against RULES.md.
#
# Usage:
#   ./validate.sh "<commit message>"
#   echo "<commit message>" | ./validate.sh
#
# Exit 0: message is valid — stdout: "OK"
# Exit 1: violations found — stderr: one VIOLATION line per rule broken,
#         stdout: best-effort mechanically fixed message (capitalize subject,
#         strip trailing period). Subject-length and body-wrap violations are
#         reported only; the skill must reword those intelligently.

set -uo pipefail

VALID_TYPES="build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test"
MAX_SUBJECT=50
MAX_BODY=72

# ---------------------------------------------------------------------------
# Read input
# ---------------------------------------------------------------------------
if [[ $# -gt 0 ]]; then
  message="$1"
else
  message="$(cat)"
fi

# Split into an array of lines
mapfile -t lines <<< "$message"
subject_line="${lines[0]}"

violations=()

# ---------------------------------------------------------------------------
# 1. Subject line — format
# ---------------------------------------------------------------------------
subject_re='^([a-zA-Z]+)(\([^)]+\))?(!)?: '

if [[ ! "$subject_line" =~ $subject_re ]]; then
  violations+=("Subject line does not match expected format 'type(scope)!: Subject' — no recognisable type prefix found")

  printf '%s\n' "${violations[@]/#/VIOLATION: }" >&2
  echo "$message"
  exit 1
fi

type_part="${BASH_REMATCH[1]}"
scope_raw="${BASH_REMATCH[2]}"   # includes surrounding parens, e.g. "(auth)"
subject_text="${subject_line#*: }"

# ---------------------------------------------------------------------------
# 2. Type must be a known Conventional Commits type
# ---------------------------------------------------------------------------
if [[ ! "$type_part" =~ ^($VALID_TYPES)$ ]]; then
  violations+=("Unknown type '${type_part}'. Allowed types: build, chore, ci, docs, feat, fix, perf, refactor, revert, style, test")
fi

# ---------------------------------------------------------------------------
# 3. Scope — at most one (no commas inside the parens)
# ---------------------------------------------------------------------------
if [[ -n "$scope_raw" ]]; then
  scope_inner="${scope_raw:1:${#scope_raw}-2}"   # strip parens

  if [[ "$scope_inner" == *","* ]]; then
    violations+=("Only one scope is allowed per commit (got '${scope_inner}'). Split into separate commits or pick the primary scope.")
  fi
fi

# ---------------------------------------------------------------------------
# 4. Subject text — capital first letter (auto-fixable)
# ---------------------------------------------------------------------------
first_char="${subject_text:0:1}"

if [[ "$first_char" =~ [a-z] ]]; then
  violations+=("Subject must start with a capital letter ('${first_char}' → '${first_char^^}')")
  subject_text="${first_char^^}${subject_text:1}"
fi

# ---------------------------------------------------------------------------
# 5. Subject text — no trailing period (auto-fixable)
# ---------------------------------------------------------------------------
if [[ "$subject_text" =~ \.$ ]]; then
  violations+=("Subject must not end with a period")
  subject_text="${subject_text%.}"
fi

# ---------------------------------------------------------------------------
# 6. Subject line total length ≤ 50 (requires intelligent rewrite by skill)
# ---------------------------------------------------------------------------
prefix="${subject_line%%: *}"
fixed_subject_line="${prefix}: ${subject_text}"
subject_len=${#fixed_subject_line}

if [[ $subject_len -gt $MAX_SUBJECT ]]; then
  violations+=("Subject line is ${subject_len} characters — max is ${MAX_SUBJECT}. Rewrite the subject to be more concise while preserving intent.")
fi

# ---------------------------------------------------------------------------
# 7. Blank line between subject and body
# ---------------------------------------------------------------------------
if [[ ${#lines[@]} -gt 1 && -n "${lines[1]}" ]]; then
  violations+=("Missing blank line between subject and body (line 2 must be empty)")
fi

# ---------------------------------------------------------------------------
# 8. Body lines ≤ 72 characters
# ---------------------------------------------------------------------------
for i in "${!lines[@]}"; do
  [[ $i -lt 2 ]] && continue

  line="${lines[$i]}"
  line_len=${#line}

  if [[ $line_len -gt $MAX_BODY ]]; then
    preview="${line:0:50}"
    violations+=("Body line $((i + 1)) is ${line_len} characters — max is ${MAX_BODY}. Rewrap: '${preview}…'")
  fi
done

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------
if [[ ${#violations[@]} -eq 0 ]]; then
  echo "OK"
  exit 0
fi

# Emit violations to stderr
for v in "${violations[@]}"; do
  echo "VIOLATION: $v" >&2
done

# Emit best-effort fixed message to stdout (only mechanical fixes applied:
# capitalise, strip period, rebuild subject line; body is unchanged)
fixed_lines=("$fixed_subject_line")

for i in "${!lines[@]}"; do
  [[ $i -eq 0 ]] && continue
  fixed_lines+=("${lines[$i]}")
done

printf '%s\n' "${fixed_lines[@]}"

exit 1
