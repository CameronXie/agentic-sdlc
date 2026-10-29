#!/usr/bin/env bash
# Repo-level lint gate: shellcheck for shell scripts, actionlint for
# GitHub Actions workflows. One definition, three runners: `make lint`,
# the pre-commit hook, and CI. Requires shellcheck and actionlint (both
# ship in the dev image; CI installs actionlint before calling this).
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

status=0

shopt -s nullglob
shell_scripts=(.githooks/* scripts/*.sh examples/*/scripts/*.sh)
if [ ${#shell_scripts[@]} -gt 0 ]; then
  echo "==> shellcheck: ${#shell_scripts[@]} script(s)"
  shellcheck "${shell_scripts[@]}" || status=1
else
  echo "shellcheck: no shell scripts found"
fi

workflows=(.github/workflows/*.{yml,yaml})
if [ ${#workflows[@]} -gt 0 ]; then
  if command -v actionlint >/dev/null 2>&1; then
    echo "==> actionlint: ${#workflows[@]} workflow(s)"
    actionlint "${workflows[@]}" || status=1
  else
    echo "ERROR: workflows present but actionlint is not installed" >&2
    status=1
  fi
else
  echo "actionlint: no workflows found"
fi

exit "$status"
