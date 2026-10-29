# layout — living spec

The repository's artifact layout and enforcement plumbing: native spec
tree, receipt enforcement in commit-msg, spec validation, skill
namespacing. Source: change `layout-foundation` (archived 2026-10-28);
decision record ADR-0002; findings F-1..F-2 on the change, F-3 resolved.

## Requirements

### Requirement: Receipt enforcement on every merge
The commit-msg hook SHALL require, for any commit whose first line starts
with `Merge `, a body line matching
`Gate: <slug> <evidence-kind> green @ <short-sha> (<date>)`. Non-merge
commits follow Conventional Commits only. `MAIN_ALLOW=1` bypasses as the
human hatch. The pre-merge-commit hook SHALL NOT exist.

#### Scenario: Merge without receipt is blocked
- **GIVEN** a branch with green changes
- **WHEN** a real `git merge --no-ff` runs with no receipt in the message
- **THEN** the merge is blocked by commit-msg naming the receipt format

#### Scenario: Merge with generalized receipt passes
- **GIVEN** the same branch
- **WHEN** the merge message body carries a valid `Gate:` line
- **THEN** the merge commits successfully with no hatch required

#### Scenario: F-3 regression — hooks survive argumentless invocation
- **GIVEN** the hooks installed in a repository
- **WHEN** git invokes any hook without arguments
- **THEN** no hook crashes; the flow completes or blocks on substance, never
  on unbound variables

### Requirement: Native spec validation
`scripts/validate-spec.sh` SHALL validate every `changes/*/spec.md` and the
living `specs/**/spec.md`: each requirement has at least one scenario; each
scenario contains GIVEN, WHEN, and THEN; each property requirement states
its domain. CI SHALL run it.

#### Scenario: Malformed delta fails
- **GIVEN** a spec delta with a requirement but no scenario
- **WHEN** validation runs
- **THEN** it exits non-zero naming the file and requirement

#### Scenario: Valid deltas pass
- **GIVEN** the archived change deltas and the living tree
- **WHEN** validation runs
- **THEN** exit zero

### Requirement: Retired tooling is gone
No third-party spec CLI directory, commands, or generated skills SHALL
remain active in the repository, and no contract SHALL reference them as
current. Historical records (ADRs, archives, acknowledgements) may mention
them.

#### Scenario: Grep finds no active references
- **GIVEN** the repository after this change
- **WHEN** active contracts and skills are searched for retired tooling
- **THEN** only historical artifacts match

### Requirement: Process skills live at the root
Process skills SHALL live in the root `.opencode/` tree, discoverable from
project directories.

#### Scenario: Skill visible from project session
- **GIVEN** an opencode session rooted in `examples/go-rest`
- **WHEN** skills are discovered (upward walk to the worktree)
- **THEN** sdlc-review is available

### Requirement: Property — CI mirrors the repo
For ANY check CI runs, the identical check SHALL be runnable locally by one
command; CI holds no private variant.

#### Scenario: CI steps map to local commands
- **GIVEN** the CI workflow file and the repo's scripts
- **WHEN** each CI step is compared to them
- **THEN** every step corresponds to `scripts/lint-repo.sh`,
  `scripts/validate-spec.sh`, or `scripts/verify-all.sh`
