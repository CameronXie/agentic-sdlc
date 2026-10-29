# ADR-0001: Architecture decisions

- Status: accepted
- Date: 2026-10-28

## Context

This directory is the first worked example of the agentic-sdlc repo: a Go
REST API whose real product is the SDLC around it — the twelve-stage
circle, machine-checked quality gates, and human approval gates working
end to end. The scaffold (this commit) establishes process only; all Go
code arrives through the SDLC itself.

## Decisions

1. **Per-project SDLC scaffold.** Each example under `examples/` carries
   its own `AGENTS.md`, `docs/`, spec tree (`specs/`), and change folders
   (`changes/<slug>/`); only git hooks and CI dispatch are repo-wide.
   Future examples in other languages replicate the shape.
2. **Stdlib-only Go REST API** (`net/http`, method-pattern `ServeMux`
   routing), in-memory storage. New dependencies are ask-first by
   contract.
3. **The verification gate is delivered by the first SDLC change**, not
   the scaffold. Its authoritative spec is
   [docs/sdlc.md](../sdlc.md); the implementing change is verified by the
   gate it delivers.
4. **One gate, three runners.** `scripts/verify.sh` runs identically in
   the agent loop, pre-commit (`VERIFY_QUICK=1`), and CI (full). No
   runner has a private variant of the gate.
5. **Native spec tree.** Spec artifacts are plain markdown
   (`changes/<slug>/` and `specs/<capability>/spec.md`), validated by
   `scripts/validate-spec.sh`; workflow commands (`/intake`, `/context`,
   `/specify`, `/plan`) are owned, in the root `.opencode/` namespace. No
   third-party spec tooling.
6. **Commit delegation, scoped.** Agents commit to feature branches in
   Conventional Commits format; push, merge, and release remain
   human/CI actions, with merge receipts enforced by the `commit-msg`
   hook.

## Consequences

- Nothing Go-shaped exists until the first change is approved — by
  design; implementing it is the handover test.
- Gate, CI, and Dockerfile changes are ask-first triggers (they define
  "quality").
- The repo stays honest: every process rule is enforced by a file, not by
  memory.
