# AGENTS.md — repo-wide contract (agentic-sdlc)

This repo demonstrates an agentic SDLC: **agents do the work, automation
enforces quality, humans make decisions.** It hosts independent example
projects under `examples/`, each a self-contained replica of the same
process shape in a different language or framework.

The composition's own process changes dogfood at the root: `specs/` is the
living spec tree for process capabilities, and `changes/<slug>/` holds each
change's intake, brief, spec, plan, evidence, and findings.

## The circle (twelve stages, numbered from zero)

| # | Stage | Owner |
|---|-------|-------|
| 0 | Intake — problem statement, reversibility tier, recovery path | **Human** |
| 1 | Context — read-only brief, open questions | Agent |
| 2 | Specify — scenarios, invariants | Agent |
| 3 | Plan — design, rejected alternatives, tasks, budget | Agent |
| 4 | **APPROVE — intent** | **Human** |
| 5 | Implement — single writer, per-task evidence | Agent |
| 6 | Verify — the gate's verbatim output | Automation |
| 7 | Review — fresh context, structured findings | Second agent |
| 8 | **APPROVE — merge**, with receipt | **Human** |
| 9 | Release — signed provenance | Automation + **Human** |
| 10 | Observe — production signals as findings | Automation |
| 11 | Learn — a check (preferred) or a rule | Agent + **Human** |

Tier (T0–T3, per the project contract) decides which stages apply; intake
and learn always run. The merge receipt reads
`Gate: <slug> <evidence-kind> green @ <short-sha> (<date>)` — the evidence
kind names what actually ran (gate output, manual review + hooks, …) and is
never overstated.

## Repo layout

- `specs/` + `changes/<slug>/` — the root dogfood: process and
  infrastructure changes walk the circle here
- `examples/<name>/` — self-contained project: its own `AGENTS.md` (the
  authoritative contract there), `docs/`, spec tree, and verification gate
  (`scripts/verify.sh`)
- `.githooks/` — pre-commit dispatcher over all project gates, Conventional
  Commits, merge-receipt check (activate once per clone:
  `git config core.hooksPath .githooks`)
- `.github/workflows/ci.yml` — runs every project's gate + spec validation;
  no runner has a private gate variant
- `docker/dev/Dockerfile` — the pinned toolchain; policy (versions,
  checksums, telemetry) lives here, never in `.env`

## Which rules apply

**Always read `examples/<name>/AGENTS.md` before working in that
directory.** The project contract carries the detail (workflow, gate, tier
thresholds, findings, quality bar); this file carries repo-wide mechanics
only. Both apply.

## Repo-wide rules

- Evidence over assertion: "done" means pasted verification output —
  everywhere, always; the receipt's evidence kind names it.
- Secrets never enter the repo, logs, or agent context (`.env` and key
  material are deny-listed in `opencode.json`).
- The enforcement surface — gates (`examples/*/scripts/verify.sh`,
  `.golangci.yml`), CI workflows, hooks (`.githooks/`), agent permissions
  (`opencode.json`), and `docker/` — is ask-first. `MAIN_ALLOW=1` is a
  human exception hatch; agents never set it.
- Commit delegation: feature branches + Conventional Commits
  (`feat fix test docs chore refactor perf build ci style`); never push,
  merge, rebase, or amend (mechanically enforced in `opencode.json` and
  `.githooks/`).

## Adding a new example project

Replicate the scaffold shape from `examples/go-rest/` (contract, docs,
spec tree, gate). It is picked up automatically: the pre-commit dispatcher,
CI dispatch, and the `instructions` glob in `opencode.json` all discover
`examples/*/` projects. Add the new project's toolchain commands to the
bash permissions in `opencode.json` — the permission surface mirrors what
the repo actually runs, nothing speculative.
