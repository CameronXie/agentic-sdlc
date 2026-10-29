# process-contract — living spec

The contracts (root and project AGENTS.md, project docs/sdlc.md) describe
the twelve-stage circle, the six-stage gate, reversibility tiers, findings,
and the receipt grammar. Source: change `contract-alignment` (archived
2026-10-28); findings F-1..F-3 on record.

## Requirements

### Requirement: Contracts describe the twelve-stage circle
The root and project AGENTS.md SHALL describe the workflow as the
twelve-stage circle, with human gates at intent approval and merge, and tier
deciding which stages apply.

#### Scenario: Workflow names every stage and owner
- **GIVEN** the updated contracts
- **WHEN** a reader walks the workflow section
- **THEN** intake, context, specify, plan, approve-intent, implement, verify,
  review, approve-merge, release, observe, and learn are each named with
  their owner (human / agent / automation)

#### Scenario: Tier selects stages
- **GIVEN** a T0 docs change
- **WHEN** its required stages are determined
- **THEN** context, plan, approve-intent, and review do not apply, and the
  change still ends in a traceable, receipted artifact

### Requirement: Gate specification is six stages with the intake chain
docs/sdlc.md SHALL specify the gate as six stages — traceability, shape,
behaviour, invariants, test quality, integration — where stage 0 checks the
scenario↔check mapping in both directions, the presence of an approved
intake, and tier consistency. Quick mode skips stages 4–5 only and prints
`skipped(<stage>, <reason>)`. New checks ship report-only before they gate.

#### Scenario: Stage 0 fails on missing intake
- **GIVEN** a change with a spec but no approved intake.md
- **WHEN** the gate runs
- **THEN** stage 0 fails naming the missing artifact

#### Scenario: Stage 0 fails on tier mismatch
- **GIVEN** a plan declaring T1 while intake records T2
- **WHEN** the gate runs
- **THEN** stage 0 fails naming both values

### Requirement: Reversibility tiers govern proof
The contract SHALL define tiers T0–T3 by undo cost, assigned by a human at
intake, recorded in intake.md, raised by anyone, lowered by nobody; a change
with no stated recovery path is T3 by default.

#### Scenario: No recovery path defaults to T3
- **GIVEN** an intake without a recovery statement
- **WHEN** tier is determined
- **THEN** the change is T3

### Requirement: Findings are structured with tier thresholds
Review findings SHALL follow the F-format (id, severity, location,
reference, claim, basis, resolution); unresolved findings at or above the
tier threshold block merge; minors never block; waivers name a human.

#### Scenario: Minor finding does not block a T1 merge
- **GIVEN** a T1 change with one unresolved minor
- **WHEN** merge is assessed
- **THEN** the merge proceeds with the finding tracked

### Requirement: Generalized receipt grammar
The documented merge receipt SHALL read
`Gate: <slug> <evidence-kind> green @ <short-sha> (<date>)`.

#### Scenario: Pre-gate docs change writes an honest receipt
- **GIVEN** no gate script exists
- **WHEN** a docs-only change merges
- **THEN** its receipt names its actual evidence kind (e.g. "manual review +
  hooks") and never claims verify.sh

### Requirement: Property — contracts make no existence claims
For ANY mechanism the contracts describe, the contract SHALL NOT claim the
mechanism is built; it specifies behavior only.

#### Scenario: Contract text audited for built-claims
- **GIVEN** any contract document in this repository
- **WHEN** it is reviewed
- **THEN** no sentence asserts a script, hook behavior, or CI capability
  exists — descriptions are normative ("SHALL"), not reportive ("is running")
