# AGENTS.md — agent contract for examples/go-rest

This directory is a worked example of the agentic-sdlc repo: **agents do the
work, automation enforces quality, humans make decisions.** Every rule below
exists to make that division mechanical, not aspirational.

## Prime directive

You (the agent) implement, test, and prove. You never self-certify: "done"
means pasted command output from the verification gate — never an assertion.
When in doubt, stop and ask; never guess silently.

## Workflow per change

1. **Intake** — `/intake <slug>` produces `changes/<slug>/intake.md`
   (problem, tier, recovery path) and the human approves it by restating
   tier and recovery path. Intake and learn run for every change; tier
   decides the rest.
2. **Context** *(from T2)* — `/context <slug>`: read-only brief: blast
   radius, touched contracts, open questions; an agent may not resolve its
   own open question.
3. **Specify + plan** — scenarios, invariants, design with rejected
   alternatives, tasks, and change budget (`/specify <slug>`, `/plan
   <slug>`; artifacts under `changes/<slug>/`). Any
   requirement asserting framework behavior cites a repro captured in the
   plan — never pin behavior from memory. The plan states size counts
   (scenarios, requirements, new capabilities, tasks) and the line budget:
   added lines vs merge-base, excluding `changes/**`, `specs/**`, and
   `*.md`.
4. **HUMAN GATE: approve intent** — no implementation before approval;
   the spec is measured against the intake.
5. **Implement** — one feature branch per change (`git switch -c
   change/<slug>`), tasks in order, evidence after every task (gate output
   once the gate exists; named tool output before — the receipt's evidence
   kind distinguishes them).
6. **Verify** — the gate's verbatim output; see the six-stage spec in
   [docs/sdlc.md](docs/sdlc.md).
7. **Fresh-context review** — a second agent (no shared session) reviews
   the diff against the spec via the `sdlc-review` skill; findings follow
   the F-format and block per the tier threshold; findings are fixed and
   re-verified before a human looks.
8. **HUMAN GATE: approve merge** — the human reviews the diff plus the
   findings. The merge commit records the receipt — `Gate: <slug>
   <evidence-kind> green @ <short-sha> (<date>)` — binding evidence to
   both the commit and the change, so it outlives the chat scroll;
   enforced by `.githooks/pre-merge-commit`.
9. **Learn** — every finding resolves into a gate check (preferred), a
   contract rule, an ADR, or explicitly nothing; archive folds the spec
   delta into the living tree at `specs/<capability>/spec.md`.

## The verification gate

`scripts/verify.sh` is the single definition of "works". Its authoritative
spec — six stages, intake chain in stage 0, quick mode, report-only
rollout — lives in [docs/sdlc.md](docs/sdlc.md). Until the gate change is
approved and merged there is intentionally no gate and no Go code; until
then, evidence is named tool output and the receipt says so honestly.

## Definition of done

- [ ] Verification evidence green — the gate's verbatim output once the
  gate exists; before that, named tool output per task, and the receipt's
  evidence kind says which
- [ ] Every scenario from the spec has a test; every property has a fuzz test
- [ ] Findings from fresh-context review resolved (or accepted by a human);
  minors tracked, never blocking below their tier
- [ ] No unexplained diff: every changed file traces to a task
- [ ] Budget respected: added lines within the plan's declared ceiling

## Branches and commits

- One branch per change, branched from `main`. Single writer: no other agent
  writes to the branch while you do.
- Conventional Commits only (`feat:`, `fix:`, `test:`, `docs:`, `chore:`,
  `refactor:`) — they drive the automated changelog and SemVer.
- You MAY: `git add`, `git commit`, `git switch`, `git branch`.
- You MUST NOT: push, merge, rebase, amend, force-push, or touch `main`
  directly. Those are human/CI actions.

## Ask-first triggers (never do these silently)

New dependencies (`go get`, `go.mod` edits) · secrets or credential material
· destructive or irreversible operations · spending · changes to the
enforcement surface — the gate (`scripts/verify.sh`, `.golangci.yml`), CI
workflows, hooks (`.githooks/`), agent permissions (`opencode.json`), or
`docker/` · anything the spec leaves ambiguous — ask, never guess.
`MAIN_ALLOW=1` is a human exception hatch; agents never set it.

## The three-way disagreement rule

If code, spec, and tests disagree, STOP. Do not pick a winner. Present the
disagreement; a human decides which is wrong — fix the code, the spec, or
the test.

## Quality bar (machine-checked; do not negotiate with yourself)

Table-driven tests generated from scenarios; fuzz tests from properties;
`golangci-lint` (staticcheck, errcheck, gosec, cyclop, revive) stays green;
complexity ceilings belong to the linter, not to your judgment.

## Code style (Go)

- Doc comments on every exported identifier; `//nolint:<linter> // reason`
  directives are load-bearing. Other comments: none unless asked.
- Errors: return them, never panic outside `main()`; wrap with `%w` when
  adding context; compare with `errors.Is/As`, never strings.
- No global mutable state, no `init()` side effects; explicit constructors —
  this is what keeps `-race` meaningful.
- Accept interfaces, return concrete structs; define interfaces where
  they're consumed.
- Initialisms capitalized (`URL`, `ID`, `HTTP`); no stuttering names
  (`server.ServerURL`). Use `time.Duration`, not bare ints.
- `context.Context` is the first parameter, never stored in a struct;
  blocking work honors cancellation (handlers read `r.Context()`;
  shutdown goes through `http.Server.Shutdown(ctx)`).
- Stdlib before dependencies (ask-first trigger); `main()` stays a thin
  shell over tested package functions — the coverage floor enforces it.

## Test conventions (Go)

- One scenario = one table case; the spec scenario name appears in the
  `t.Run` name. Prefer black-box tests (`package foo_test`).
- Write the scenario's failing test before its implementation (red →
  green); refactors pin existing behavior with a characterization test
  before touching code.
- Hermetic by default: listen on `:0` (never fixed ports), `t.TempDir()`,
  `t.Setenv` (never `os.Setenv`), poll with deadline (never `time.Sleep`),
  no network, seeded randomness.
- Properties = fuzz tests; the property's stated domain becomes the fuzz
  harness's input guard (skips are for malformed inputs only); seed every
  boundary discovered in flight (e.g. `//healthz`, `/healthz#0`).
- Assert errors with `errors.Is`, never message substrings.
- Gate tests: exec the real script, pin the runner mode via an explicit env
  builder (`VERIFY_QUICK` never inherited); injected defects uniquely named
  and removed in `t.Cleanup`; the suite exercises every documented mode.
