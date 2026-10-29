---
name: sdlc-review
description: Fresh-context review of a completed OpenSpec change against its spec deltas, the AGENTS.md quality bar, and gate evidence. Use when every task in tasks.md is complete and scripts/verify.sh is green, before the human merge gate. Must run in a fresh session that did not implement the change.
license: MIT
metadata:
  reference: "patterned on obra/superpowers requesting/receiving-code-review; bound to examples/go-rest docs/sdlc.md"
---

# Fresh-context SDLC review

You are the second agent: you did NOT implement this change. Review the
branch **against its spec, not just the diff**. You emit findings; you never
edit the branch (single-writer — fixes happen in the implementing session).

## Inputs

- Change slug: from the request, or derive from the branch name `change/<slug>`.

## Risk tier (deterministic, derived from the diff)

Compute `git diff --name-only main...change/<slug>` and classify:

- **HIGH** — the diff touches an ask-first surface (`scripts/verify.sh`,
  `.golangci.yml`, `.github/`, `.githooks/`, `docker/`, `opencode.json`,
  `go.mod`/`go.sum`) or adds a dependency. Depth: every checklist item
  mandatory; re-run `scripts/verify.sh` yourself and cite its output;
  report findings at all severities; name each ask-first surface touched
  and whether a recorded human approval exists for it.
- **STANDARD** — everything else; normal checklist depth.

The tier scales depth only — a fresh-context review happens for every
change; no tier skips it. You derive the tier from the diff, never from the
implementer's claim. State the tier in your verdict line.

## Procedure

1. **Load the spec**: read `changes/<slug>/spec.md` (the change delta) and,
   for context, the living tree at `specs/<capability>/spec.md` — every
   requirement, scenario, and property is your acceptance contract.
2. **Load the code**: `git diff main...change/<slug>` (plus `--stat` for
   orientation; every changed file must trace to a task).
3. **Load the bar**: this project's `AGENTS.md` (quality bar, code style,
   test conventions) and `docs/sdlc.md` (review checklist, gate spec).
4. **Budget evidence**: run
   `git diff --numstat $(git merge-base main change/<slug>)` — additions
   only, excluding `openspec/**` and `*.md`. Paste the actual next to the
   estimate stated in `proposal.md`. An overrun ≈2× without a recorded
   reason is a finding.
5. **Trace every scenario**: each Given/When/Then scenario → a table case
   whose `t.Run` name contains the scenario name; each property → a fuzz
   test whose input guard matches its stated domain. Anything missing is a
   BLOCKER.
6. **Verify gate claims**: the implementing session's evidence must be
   pasted gate output, not assertions. You may re-run `scripts/verify.sh`
   to check; cite what you saw.
7. **Checklist sweep**: Design · Functionality · Complexity · Tests ·
   Naming · Comments · Style · Docs — against the spec (after Google
   eng-practices).

## Findings format

One line each, ordered by severity:

`[BLOCKER|MAJOR|MINOR] file:line — spec ref (requirement/scenario) — what — suggested fix`

- **BLOCKER**: scenario unimplemented or untested; gate not green; budget
  overrun unexplained; changed file that traces to no task.
- **MAJOR**: works but violates code style / test conventions / a recorded
  design decision.
- **MINOR**: polish. Never blocks merge.

## Output

- Verdict first: `CLEAN` (ready for the human merge gate) or `FINDINGS`
  (fix → re-run gate → re-review BLOCKERs/MAJORs).
- The findings list, each with file:line evidence.
- Do not merge, archive, or edit anything — those are human gates and the
  implementing session's job.

## Guardrails

- Findings need evidence (file:line, cited output) — no impressions.
- Severity is not negotiable upward; minors never block.
- You review; you do not gate, merge, or fix.
