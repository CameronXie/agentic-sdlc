# Runbook — examples/go-rest

## Everyday commands

| Action                    | Command                                        |
|---------------------------|------------------------------------------------|
| Verification gate (full)  | `make verify` or `scripts/verify.sh` (from M0) |
| Verification gate (quick) | `VERIFY_QUICK=1 scripts/verify.sh` (from M0)   |
| Run API locally           | `make run` (from M0)                           |
| Rebuild dev container     | `make up` (repo root)                          |

Note: gate and run commands exist once the first change (`bootstrap-gate-and-healthz`) lands; the scaffold ships process
only.

## Environment

- No service env vars yet; configuration arrives with the feature that needs
  it (12-factor config via `.env` + docker-compose, never hardcoded secrets).
- Toolchain policy — pinned versions, checksums, telemetry off — lives in
  `docker/dev/Dockerfile`.

## Rollback

- Pre-release (now): `git revert <merge-commit>` on `main`, re-run the gate.
- Post-M3: `git revert` plus a re-cut release; production rollback stays one
  runbook command, never improvisation.

## Incidents

- SEV1/2: a human commands; the agent investigates and drafts the timeline.
- After resolution: blameless postmortem from
  [postmortem-template.md](postmortem-template.md). Ask of every failure:
  which gate should have caught it?
