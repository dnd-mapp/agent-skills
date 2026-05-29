#!/usr/bin/env bash
# Validates a Pull Request body against the rules in SKILL.md.
#
# Usage:
#     ./validate.sh "<pr body>"
#     echo "<pr body>" | ./validate.sh
#
# Exit 0: body is valid — stdout: "OK"
# Exit 1: violations found — stderr: one VIOLATION line per rule broken
#
# Checks:
#     1. Empty sections — a heading followed only by HTML comments (no real content)
#     2. Unfilled placeholders — HTML comments still present in the submitted body
#     3. Hard-wrapped prose — paragraph lines that end before 80 characters
#        (excludes headings, list items, code blocks, and blank lines)

set -uo pipefail

# ---------------------------------------------------------------------------
# Read input
# ---------------------------------------------------------------------------
if [[ $# -gt 0 ]]; then
    body="$1"
else
    body="$(cat)"
fi

mapfile -t lines <<< "$body"
violations=()

# ---------------------------------------------------------------------------
# State tracking for section and code-block detection
# ---------------------------------------------------------------------------
current_heading=""
current_heading_level=0
section_has_content=false
in_code_block=false
prev_line_was_text=false

flush_section() {
    if [[ -n "$current_heading" && "$section_has_content" == false ]]; then
        violations+=("Section '${current_heading}' is empty — remove it if it does not apply")
    fi
}

for i in "${!lines[@]}"; do
    line="${lines[$i]}"

    # Track fenced code blocks — lines inside are exempt from all checks
    if [[ "$line" =~ ^\`\`\` ]]; then
        in_code_block=$([ "$in_code_block" == true ] && echo false || echo true)
        prev_line_was_text=false
        continue
    fi

    [[ "$in_code_block" == true ]] && continue

    # -------------------------------------------------------------------------
    # 1 & 2. Section tracking and unfilled placeholder detection
    # -------------------------------------------------------------------------
    if [[ "$line" =~ ^#{1,6}[[:space:]] ]]; then
        heading_level="${line%%[^#]*}"
        heading_level="${#heading_level}"
        current_level="${current_heading_level:-0}"

        if [[ $heading_level -le $current_level || -z "$current_heading" ]]; then
            # Sibling or parent heading — flush current section before starting new one
            flush_section
            current_heading="${line#*# }"
            current_heading_level=$heading_level
            section_has_content=false
        else
            # Sub-heading counts as content for its parent section
            section_has_content=true
        fi
        prev_line_was_text=false
        continue
    fi

    if [[ "$line" =~ ^\<\!-- ]]; then
        # 2. Unfilled placeholder — any HTML comment still present is a violation
        violations+=("Unfilled placeholder on line $((i + 1)): ${line}")
        prev_line_was_text=false
        continue
    fi

    if [[ -z "$line" ]]; then
        prev_line_was_text=false
        continue
    fi

    # Non-empty, non-comment, non-heading line — section has real content
    section_has_content=true

    # -------------------------------------------------------------------------
    # 3. Hard-wrapped prose detection
    #    A line is considered a hard-wrap if:
    #    - It is not a heading, list item, blockquote, or blank line
    #    - It is shorter than 80 characters
    #    - The NEXT line is also non-blank, non-heading, non-list prose
    #      (meaning this line was broken mid-paragraph)
    # -------------------------------------------------------------------------
    is_prose=true
    list_re='^[[:space:]]*[-*+>]'
    heading_re='^#{1,6}[[:space:]]'

    if [[ "$line" =~ $list_re ]]; then
        is_prose=false;
    fi   # list / blockquote
    if [[ "$line" =~ $heading_re ]]; then
        is_prose=false;
    fi   # heading
    if [[ "$line" == \|* ]]; then
        is_prose=false;
    fi   # table row

    if [[ "$is_prose" == true && "$prev_line_was_text" == true ]]; then
        # Look back: if the previous line was also short prose, that previous
        # line was hard-wrapped mid-paragraph.
        prev_line="${lines[$((i - 1))]}"
        prev_len=${#prev_line}

        if [[ $prev_len -lt 80 && $prev_len -gt 0 ]]; then
            violations+=("Hard-wrapped prose at line ${i}: line ends at ${prev_len} characters — write prose as unwrapped lines and let GitHub reflow it")
        fi
    fi

prev_line_was_text="$is_prose"
done

# Flush the final section
flush_section

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
