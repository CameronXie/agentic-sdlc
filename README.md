# agentic-sdlc

**What does a software lifecycle look like when agents do the work — intake to
production and back again?**

This repository is a working investigation, not a product. It composes the
practices that already work, invents the ones that don't exist yet, and states
its reasoning so the pieces can be argued with, replaced, or thrown out.

**Current working answer: proof in proportion to irreversibility.**

> Spec-driven development is a *component* of this repository, not its subject.
> We adopt it for the stage it solves, and spend our attention on the ten stages
> around it.

---

## What actually changed

Agents made implementation cheap. They did not make **deciding** cheap, and they
did not make **being wrong** cheap. The entire design falls out of three
consequences.

### 1. Intent became the bottleneck

Code satisfying a vague specification is indistinguishable from code satisfying
the wrong one. The scarce judgement is no longer *can we build this* but *should
we, and what exactly is it*. Review is where that ambiguity surfaces — late,
expensively, and via the person least able to hold the change in their head. **Every review finding is a decision that
should have been made upstream.**

### 2. Nobody authored the change

Trust used to be amortised over a person's track record and passed colleague to
colleague. Now every change must pay for its own, in artifacts that outlive the
conversation: spec, evidence, findings, attestation. This is an accountability
problem before it is a quality problem.

### 3. The agent is the least reliable witness to its own work

It reports success it has not achieved, and it writes its tests from the same
misunderstanding that produced the code. Any judgement left with the agent about
its own output is not a judgement.

---

## Three commitments

Everything in this repo derives from these. They are the current best answer, not
settled truth — each has a hypothesis attached at the end of this document.

### I. Proof in proportion to irreversibility

> How much proof a change must carry is a function of how hard its mistakes are
> to undo.

Cheap-to-reverse changes move fast and learn in production. Hard-to-reverse
changes — migrations, auth, deletion, published artifacts, external contracts —
pay for proof before they ship. Uniform ceremony is wrong in both directions: a
tax on the first category, insufficient for the second, and the reason people
route around processes.

### II. The specification is the source

Code implements it. The gate is its executable shadow. Traceability runs both
ways and is mechanically checked — not asserted in prose.

### III. No party judges its own work

Every stage exists to remove a judgement from a party with an interest in the
answer. The agent doesn't certify its output; the authoring context doesn't
review it; the test suite doesn't grade itself; the branch doesn't vouch for its
own green.

### On roles

Agents implement and prove. Automation defines and enforces "done". Humans decide
what cannot yet be mechanized.

**This is an observation about current capability, not a commitment.** When a
judgement becomes mechanizable, it moves — and the contract records that it
moved, and why. A capability boundary treated as axiomatic becomes a period
piece.

---

## Where practice exists, and where it doesn't

An honest map of what this repo *borrows* versus what it is *inventing*. The
third column is the actual work.

| Phase         | Settled practice we adopt                                                              | What this repo is testing                                                                                  |
|---------------|----------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------|
| **Intake**    | Little — prioritisation methods assume implementation is the constraint                | Who decides a change deserves to exist, and how reversibility is assigned at the door                      |
| **Context**   | Context-engineering practice; repo-versioned agent instructions                        | Whether ambiguity can be *surfaced* instead of invented, via a read-only stage with an open-questions rule |
| **Specify**   | **Spec-driven development, adopted wholesale** — scenarios, invariants, spec-as-source | Only whether the spec stays the source under real velocity, rather than decaying into documentation        |
| **Design**    | ADR practice                                                                           | How a decision gets *routed out* of a change so it outlives it                                             |
| **Implement** | Verify-script culture; single-writer branching                                         | Bounded runs: stop rules, change budgets, stage-scoped permissions                                         |
| **Test**      | Table tests, property-based testing, mutation testing                                  | Mutation score as a **blocking** signal on agent-authored tests, not a report                              |
| **Review**    | Maker/checker separation                                                               | Findings as structured artifacts with a resolution lifecycle                                               |
| **Merge**     | Branch protection, required checks                                                     | Accountability when no individual can personally verify the change                                         |
| **Release**   | SLSA, in-toto, Sigstore, keyless signing                                               | Provenance that names the *agent and model*, not just the builder                                          |
| **Operate**   | Progressive delivery, rollback, observability                                          | Production signals re-entering as findings against the spec                                                |
| **Learn**     | Postmortem practice                                                                    | Keeping a contract from rotting as rules accumulate                                                        |

**Nothing here is a critique of the practices in column two.** They are load-bearing.
The thesis is that assembling them into a closed circle — with reversibility
deciding how much of the circle applies — is a different problem from any of them
individually.

---

## The specification is the source

The living spec tree under `specs/` is the primary artifact of this repository.
Code implements it; `verify.sh` shadows it.

That relationship is checked, not claimed:

- **Every scenario maps to a check.** A scenario with no executable consequence
  is a gap.
- **Every check maps to a scenario.** A check with no spec node is debt — it
  encodes an expectation nobody wrote down.
- **Divergence is reconciled before merge.** If implementation forced a different
  approach, the spec is amended while the change is still open. A spec that lags
  its code has stopped being a source.

This is why the gate's first stage is traceability rather than compilation. Code
that satisfies untraceable checks is self-consistent, not correct.

---

## The full circle

Twelve stages, numbered from zero. Each emits a durable artifact; none trusts
the previous one on assertion alone. The right-hand column *is* the design.

| #  | Stage                        | Owner                   | Artifact                                                 | Takes judgement from                                  |
|----|------------------------------|-------------------------|----------------------------------------------------------|-------------------------------------------------------|
| 0  | **Intake**                   | **Human**               | Problem statement, reversibility tier, recovery path     | The agent — it cannot decide what deserves to exist   |
| 1  | **Context** *(read-only)*    | Agent                   | Blast radius, touched contracts, **open questions**      | The agent — it may not resolve its own ambiguity      |
| 2  | **Specify**                  | Agent                   | Scenarios, invariants, non-functional obligations        | Nobody — this is the source                           |
| 3  | **Plan**                     | Agent                   | Design, rejected alternatives, tasks, change budget      | The change — constraining decisions leave as ADRs     |
| 4  | **Approve — intent**         | **Human**               | Approved spec + plan                                     | The agent — intent is not self-evident from a diff    |
| 5  | **Implement**                | Agent *(single writer)* | Branch, per-task gate output                             | The session — budgets and stop rules are external     |
| 6  | **Verify**                   | Automation              | Verbatim gate output, all stages                         | The agent — it does not grade its own work            |
| 7  | **Review** *(fresh context)* | Second agent            | Findings                                                 | The author — a context that wrote it cannot review it |
| 8  | **Approve — merge**          | **Human**               | Merge commit + CI attestation                            | The branch — local green is never final               |
| 9  | **Release**                  | Automation + **Human**  | Signed artifact with build provenance                    | The build — signing material sits outside build steps |
| 10 | **Observe**                  | Automation              | Production signals as findings                           | The suite — production is the only authority          |
| 11 | **Learn**                    | Agent + **Human**       | A gate check *(preferred)* or contract rule *(fallback)* | Memory — rediscovery is a process defect              |

**Not every change walks all twelve.** Tier decides which apply. The common
misreading of spec-driven process is that ceremony is the virtue; it isn't — **traceability** is. A T0 change skipping
stages 1, 3, 4, and 7 still produces an
attested, traceable artifact.

### Why intent is approved mid-flight

There's a credible counter-position: run the pipeline uninterrupted and bring the
human in only at a finished PR, because interruption destroys the speed advantage
and partial work reviews badly. We approve intent early anyway, on one argument — **wrong intent is invisible in a
finished diff, and rework costs more than a short
wait.** T0 and T1 take the uninterrupted path precisely because that argument
weakens as reversibility rises.

---

## Reversibility tiers

Assigned by a human at intake, recorded in `changes/<slug>/intake.md` together
with any later escalation. **Tier may be raised by anyone at any stage and
lowered by nobody.** An agent may escalate; it may never de-escalate.

| Tier   | Undo cost             | Example                                       | Recovery path                         | Stages                                              | Findings that block               |
|--------|-----------------------|-----------------------------------------------|---------------------------------------|-----------------------------------------------------|-----------------------------------|
| **T0** | Seconds               | Docs, comments, formatting                    | `git revert`                          | 0, 2, 5, 6, 8, 11 *(light)*                         | blocker                           |
| **T1** | Minutes               | Internal refactor, no contract change         | Revert + redeploy                     | 0, 2, 5, 6, 7, 8, 11                                | major and above                   |
| **T2** | Hours, user-visible   | New capability, API surface change            | Flag off, then revert                 | 0–8, 11                                             | major and above                   |
| **T3** | Not fully recoverable | Migration, auth, deletion, published artifact | Rehearsed rollback + incident process | All, plus adversarial review and rollback rehearsal | blocker (all severities reviewed) |

Every tier keeps intake (tier assignment) and learn (the loop closes or nothing
improves); stages 9 and 10 apply at release boundaries regardless of the tier of
any individual change. Minors never block; they are tracked.

**A change with no stated recovery path is T3 by default.** "We'd figure it out"
is not a recovery path.

### Irreversibility surfaces

Declared in the contract, matched mechanically against the diff. Touching any of
these forces T3 **regardless of apparent change size** — because the one-line
config change that causes an outage is the canonical agentic failure, and the
agent is the wrong party to assess its own blast radius.

```
schema/           migrations, data model changes
auth/             identity, permissions, tokens
contracts/        published API surface, event schemas
*delete* *drop* *truncate* *purge*
release/          anything producing a consumable artifact
infra/            anything not re-provisionable from source
```

### A spike is not a tier

Exploratory work is allowed, read-only or on a throwaway branch, and **spike code
never merges.** Its only legitimate outputs are a context brief or an ADR.

---

## The gate

One script. Fixed stage order. Fail-fast. Identical under three runners — the
agent loop, the pre-commit hook, and CI.

| Stage               | Question it answers                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------|
| **0. Traceability** | Does every check map to a spec node, every scenario to a check — and does an approved intake exist whose tier matches? |
| **1. Shape**        | Does it build, lint, type-check, and meet commit conventions?                                                          |
| **2. Behaviour**    | Do the spec's scenarios hold? *(table test per scenario)*                                                              |
| **3. Invariants**   | Do the stated properties hold under generated input? *(property / fuzz)*                                               |
| **4. Test quality** | **Would the tests notice if the code were wrong?** *(mutation score on the diff)*                                      |
| **5. Integration**  | Does it work against a real environment, judged by something other than the agent?                                     |

Mapping to a conventional Go gate (fmt, imports, vet, lint, build,
race+coverage, coverage floor, smoke): Shape absorbs the first five; Behaviour
absorbs race and the coverage floor; Integration is the smoke stage. Nothing is
lost; two stages are added. Quick mode (`VERIFY_QUICK=1`, the pre-commit runner)
skips stages 4 and 5 only, and prints `skipped(<stage>, <reason>)` so evidence
always shows what did not run.

### Why stage 0 is first

Everything after it is meaningful only relative to the spec.

### Why stage 4 exists

Coverage measures *execution*, not *verification*. An agent authoring both the
implementation and its tests encodes one misunderstanding twice — and the result
looks entirely professional while catching a fraction of real defects. Mutation
testing is the one cheap signal that can't be gamed by touching more lines:
inject faults into changed code; a surviving mutant fails the gate.

- Scope to changed code; incremental/diff mode.
- Score-based exit code — the score **gates**; it does not file a report.
- Surviving mutants reviewed before generated tests are accepted.
- Genuine survivors return to the test-authoring agent as targeted work.

### The test-oracle trap

An agent writing a test to satisfy *observed* behaviour, without first
establishing that the behaviour is correct, promotes a bug to a specification.
So: **acceptance tests derive from approved scenarios, never from observed
output**, authored in a context that did not write the implementation.

### CI is the backstop

A session can edit any file — *including the gate*. So the identical gate re-runs
where the session cannot reach it. Local green is never final.

### Who may weaken the gate

Loosening a check, lowering a threshold, or skipping a stage is a **separate
human approval**, stricter than merge approval. CI protects the result; nothing
protects the *definition* except this rule.

### Flake policy

Non-determinism gets a mechanical response: quarantine, issue, deadline. Without
one, agents learn to re-run until green — the most corrosive habit available to
them.

---

## Bounded runs

The layer above context files: the control structure around a recurring agent run.

**Stop rules.** A run halts when verification passes · the iteration cap is
reached · **the same failure repeats** · the next action needs wider permissions
than the stage grants · cost exceeds budget · the agent can no longer tie its next
action to observed evidence.

**Change budget.** Each plan declares maximum files, diff lines, and tasks.
Exceeding it is a *specification error* — the change was too large — not
permission to continue.

**Permission scoping by stage.** Read-only during context, specify, plan, and
review; write during implement. `opencode.json` is the permission surface and
mirrors what the repo executes.

**Session handoff.** Task status and decisions live in files. A context reset must
not lose the thread. *Chat history is not memory.*

---

## Accountability and provenance

The naive answer is a merge receipt: a human-typed commit trailer attesting to
evidence the implementing party selected and pasted. That is a transcription of
self-reported results, with no signature and no independent runner —
self-certification wearing a uniform, and a direct violation of commitment III.

**Instead:** CI issues a signed build-provenance attestation bound to the
workflow identity, with signing material inaccessible to user-defined build steps.
Merge approval checks the attestation, not a trailer.

```
Attestation covers:
  the gate that ran, and its stage results
  the commit SHA it ran against
  the workflow identity that produced it
  the toolchain digest from the pinned dev image
```

**Direction of travel:** bind authoring agent identity and model version into the
provenance of agent-authored commits, so *which agent, which model, under which
contract version* is answerable afterwards rather than reconstructed from memory.

---

## Findings

Review output that lives in chat is not review output. Every finding is a
structured artifact:

```
id:         F-<change-slug>-<n>
severity:   blocker | major | minor | note
location:   <path>:<line> | <artifact>
reference:  <spec scenario, invariant, ADR, or contract rule>
claim:      what is wrong
basis:      the evidence for the claim
resolution: fixed <sha> | deferred <issue> | waived <reason + approver>
```

- Unresolved findings at or above the tier threshold block merge, mechanically.
- A waiver names a human. "Agreed with the agent" is not a resolution.
- **A finding is a symptom of a missing check.** The response is to ask which
  earlier stage should have caught it, and move detection left.

So *findings per KLOC* is a **leading indicator of gate gaps**, not a quality
score. Reducing it by reviewing less is cheating; reducing it by adding checks is
the point.

---

## The learn loop

Each finding — from review, verification, or production — resolves into exactly
one of:

1. **A gate check** — preferred, always, where mechanizable.
2. **A contract rule** — only where it cannot be mechanized.
3. **An ADR** — where it is a decision, not a defect.
4. **Nothing**, explicitly and with a reason. Not every finding deserves a rule.

### Two failure paths, not one

| Failure          | Meaning                                    | Resolves against                                    |
|------------------|--------------------------------------------|-----------------------------------------------------|
| **Defect**       | Built wrong                                | Code, tests, gate                                   |
| **Wrong intent** | Built correctly; shouldn't have been built | The **spec process** — intake, context, or approval |

Conflating these is how a process learns the wrong lesson. Wrong intent is never
fixed by adding a check to the gate — it feeds back as a new intake or context
checklist item, so the next change asks the question at the door.

### Keeping the contract alive

Rules accumulate, contracts bloat, agents start ignoring the file wholesale.
Enforced countermeasures:

- **Provenance.** Every rule cites the finding that created it. Rules without
  provenance are deleted on sight.
- **Size ceiling.** A hard budget. Hitting it forces consolidation, not an
  exemption.
- **Eviction.** A rule that has never demonstrably prevented anything is noise.
- **Promotion.** Any rule that becomes mechanizable converts to a check and is
  struck from the contract.

---

## Vocabulary

The first distinction matters most.

| Term                        | Meaning                                                                                                                                      |
|-----------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| **Gate**                    | The automated verification script (`scripts/verify.sh`). Staged, fail-fast; exit code is the verdict. **Always automated — never a person.** |
| **Approval**                | A human decision that unblocks the pipeline: intent, merge, release, gate weakening. **Always a person — never automated.**                  |
| **Contract**                | `AGENTS.md` — the machine-targeted constitution, consulted by workflow commands rather than restated per change.                             |
| **Spec tree**               | `specs/` — the living source of truth.                                                                                                       |
| **Context brief**           | Read-only survey preceding any spec: blast radius, touched contracts, open questions.                                                        |
| **Open question**           | A recorded ambiguity. **An agent may not resolve its own.**                                                                                  |
| **Evidence**                | Verbatim gate output. Not a summary, not "tests pass".                                                                                       |
| **Finding**                 | Structured defect or gap, with severity, reference, basis, and resolution.                                                                   |
| **Attestation**             | CI-issued signed statement that a specific gate ran green against a specific commit.                                                         |
| **Reversibility tier**      | T0–T3 by undo cost. Determines which stages apply.                                                                                           |
| **Irreversibility surface** | A declared path or pattern that forces T3 on contact.                                                                                        |

---

## Repository layout

```
specs/                  living spec tree — the composition's own process
changes/<slug>/         process/infrastructure changes: intake, brief, spec,
                        plan, evidence, findings (the repo dogfoods at root)
examples/<name>/        self-contained project:
                          AGENTS.md          — the contract (constitution)
                          specs/             — living spec tree (the source)
                          docs/              — SDLC, runbook, ADRs
                          changes/<slug>/    — brief, spec, plan, evidence, findings
                          scripts/verify.sh  — the gate (the spec's shadow)
.githooks/              pre-commit gate dispatch, Conventional Commits,
                        attestation presence check
.github/workflows/      CI: gate per project, spec/trace validation, attestation
docker/dev/             pinned toolchain (versions, checksums, telemetry off)
scripts/                repo-level lint + gate dispatcher
opencode.json           agent permission surface; mirrors what the repo executes
```

---

## Quickstart

**Prerequisites:** Git, Docker, `make`, and the `opencode` CLI. Everything else is
pinned inside the dev image.

```
git config core.hooksPath .githooks   # once per clone: activate commit-time checks
make up                               # build/refresh the pinned dev environment
cd examples/go-rest
opencode                              # then: /intake <change-slug>
```

Authoritative docs, in reading order:

1. [AGENTS.md](AGENTS.md) — repo mechanics
2. [examples/go-rest/AGENTS.md](examples/go-rest/AGENTS.md) — the agent contract
3. [examples/go-rest/docs/sdlc.md](examples/go-rest/docs/sdlc.md) — stages,
   approvals, gate specification, tier table

---

## Scope

**This is:** a reference composition — a working repository you read, copy, and
adapt, with every moving part visible and replaceable, and a shape meant to be
replicated across example stacks.

**This is not:** a framework, a CLI, a product, or a dependency. There is nothing
to install. If a piece here is wrong for you, delete it; the process should
survive the substitution.

### Deliberate non-goals

- **Multi-agent orchestration.** Parallel *writers* stay out until the
  single-writer circle is proven; concurrency masks the failures this repo exists
  to observe. Parallel read-only subagents are already in scope.
- **Packaging as a framework.** Never — nothing to install, nothing to depend
  on; copy the composition or don't.
- **Autonomy as a goal.** The target is *verifiable* delivery, not unattended
  delivery. Removing a human approval is a consequence of mechanizing a
  judgement, never an objective.

---

## Hypotheses under test

This repo exists to falsify these, not to illustrate them. The first three test
the commitments directly.

- **H1 — Proof can be proportioned.** Tiering by reversibility beats uniform
  ceremony on both throughput and escaped-defect cost.
- **H2 — The spec can stay the source.** Bidirectional traceability survives real
  change velocity rather than decaying into documentation.
- **H3 — Self-certification can be eliminated end to end.** Every judgement can be
  relocated to a disinterested party without the process stalling.
- **H4 — Test quality is gateable.** Mutation score on the diff is a usable
  blocking signal, not an unaffordable report.
- **H5 — Ambiguity can be surfaced rather than invented.** A read-only context
  stage with an open-questions gate measurably reduces rework from misread intent.
- **H6 — The learn loop converges.** Findings become checks faster than the
  contract accumulates prose.
- **H7 — Borrowed pieces stay replaceable.** Swapping any third-party component
  must not fork the process.

**Instrumentation**, so these stay answerable rather than assertable: fix-loop
iterations per change · findings per KLOC *by stage of origin* · mutation score
trend · open questions raised vs. human-answered · tier escalations after intake ·
estimate-vs-actual drift · contract size over time.

---

## Open questions

Unsettled, and stated rather than hidden.

1. **What is the unit of change?** One spec per feature, per PR, or per task?
   Everything downstream inherits this choice.
2. **How are competing changes sequenced?** Single writer per *change* is clear;
   single writer per *repository* is a throughput ceiling — deliberate, or to be
   solved?
3. **How is tier mis-assignment caught?** Escalation-only helps, but a T3 change
   that trips no irreversibility surface still walks the light path.
4. **How is a spec retired?** Capabilities get deleted; the spec tree has no
   removal story.
5. **What happens when the gate is wrong?** A false red blocks correct work, and
   the weakening-approval rule makes legitimate correction slow.

---

## Prior art & acknowledgements

This is a composition, and the ingredients are not ours: the spec-driven
development community and the specify → plan → tasks → implement shape; the
"constitution" pattern of one project-rules file consulted by every workflow
command; context- and loop-engineering practice around stop rules, budgets, and
verifier subagents; agent skill-pack methodologies, including published
property-based-testing skills; mutation testing as a quality gate for generated
tests; maker/checker review structures; verify-script CI culture;
progressive-delivery and rollback practice; and supply-chain attestation practice (SLSA, in-toto, Sigstore).

The standing commitment: track what is borrowed, re-check it against upstream
releases, and **upgrade rather than fork**.

---

## License

Not yet chosen.