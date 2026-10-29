#!/usr/bin/env bash
# Runs every example project's verification gate (full mode by default;
# VERIFY_QUICK=1 in the environment passes through to each gate).
# Dormant until a project has scripts/verify.sh. One definition, three
# runners: `make verify`, the pre-commit hook (quick), and CI (full).
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

shopt -s nullglob
gates=("$repo_root"/examples/*/scripts/verify.sh)
shopt -u nullglob

if [ ${#gates[@]} -eq 0 ]; then
  echo "verify-all: no project gates yet (examples/*/scripts/verify.sh); nothing to do"
  exit 0
fi

failed=0
for gate in "${gates[@]}"; do
  project_dir="$(cd "$(dirname "$gate")/../.." && pwd)"
  echo "==> gate: $(basename "$project_dir")"
  if ! bash "$gate"; then
    echo "FAILED: gate for $(basename "$project_dir")" >&2
    failed=1
  fi
done

exit "$failed"
