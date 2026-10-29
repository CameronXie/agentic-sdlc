#!/usr/bin/env bash
# Validates spec structure for active changes and the living spec tree:
#   - every "### Requirement:" has at least one "#### Scenario:" block
#   - every scenario contains GIVEN, WHEN, and THEN
#   - every "Property" requirement states its domain ("For ANY" or "domain")
# Usage: validate-spec.sh [files-or-dirs...]
#        (default: changes/*/spec.md and specs/*/spec.md from the repo root)
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

if [ $# -gt 0 ]; then
  targets=("$@")
else
  shopt -s nullglob
  targets=(
    "$repo_root"/changes/*/spec.md
    "$repo_root"/specs/*/spec.md
    "$repo_root"/examples/*/changes/*/spec.md
    "$repo_root"/examples/*/specs/*/spec.md
  )
  shopt -u nullglob
fi

failed=0
checked=0

check_file() {
  local file="$1" out
  out=$(awk '
    function flush_req() {
      if (req != "" && scen_count == 0)
        printf "  requirement has no scenario: %s\n", req
      if (req != "" && isprop && body !~ /For ANY|domain/)
        printf "  property requirement lacks a stated domain: %s\n", req
      req = ""; scen_count = 0; isprop = 0; body = ""
    }
    function flush_scen() {
      if (scen != "" && (g == 0 || w == 0 || t == 0))
        printf "  scenario missing GIVEN/WHEN/THEN: %s\n", scen
      scen = ""
    }
    /^### Requirement:/ {
      flush_scen(); flush_req()
      req = $0; isprop = ($0 ~ /Property/); body = ""
      next
    }
    /^#### Scenario:/ {
      flush_scen(); scen = $0; scen_count++
      g = 0; w = 0; t = 0
      next
    }
    {
      if (req != "") body = body " " $0
      if (scen != "") {
        if ($0 ~ /GIVEN/) g = 1
        if ($0 ~ /WHEN/) w = 1
        if ($0 ~ /THEN/) t = 1
      }
    }
    END { flush_scen(); flush_req() }
  ' "$file")
  if [ -n "$out" ]; then
    echo "FAIL: $file"
    echo "$out"
    failed=1
  fi
}

for target in "${targets[@]}"; do
  if [ -d "$target" ]; then
    shopt -s nullglob
    files=("$target"/*/spec.md "$target"/spec.md)
    shopt -u nullglob
  else
    files=("$target")
  fi
  for file in "${files[@]}"; do
    if [ -f "$file" ]; then
      checked=$((checked + 1))
      check_file "$file"
    fi
  done
done

if [ "$checked" -eq 0 ]; then
  echo "validate-spec: no spec files found" >&2
  exit 1
fi

if [ "$failed" -ne 0 ]; then
  echo "validate-spec: FAILED ($checked file(s) checked)" >&2
  exit 1
fi

echo "validate-spec: OK ($checked file(s) checked)"
