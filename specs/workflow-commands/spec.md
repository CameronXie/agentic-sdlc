# workflow-commands — living spec

The four front-half commands that make the flow runnable by a newcomer:
`/intake`, `/context`, `/specify`, `/plan`. Source: change `flow-skills`
(2026-10-28; change history not retained in the handover tree).

## Requirements

### Requirement: Intake interviews and stages the problem
The `/intake` command SHALL interview the human (one question at a time,
converting solution-shaped requests into problem statements), propose a
reversibility tier by recovery-path reasoning (no stated path ⇒ T3
proposed), draft `changes/<slug>/intake.md` with `approved_by: PENDING`,
and stop for human approval — which requires the human to restate tier and
recovery path in their own words.

#### Scenario: Solution-shaped request is returned as a question
- **GIVEN** a request naming a technology instead of a problem
- **WHEN** /intake runs
- **THEN** its first substantive question asks what the change would make
  true, not how to build the named technology

#### Scenario: No recovery path proposed as T3
- **GIVEN** the human cannot state how the change would be undone
- **WHEN** /intake drafts the artifact
- **THEN** tier T3 is proposed with the default noted

#### Scenario: Artifact is not approved until restated
- **GIVEN** a drafted intake.md
- **WHEN** the human has not restated tier and recovery path
- **THEN** approved_by remains PENDING and downstream commands refuse the
  change

### Requirement: Context surveys before specifying
The `/context` command SHALL produce a read-only brief
(`changes/<slug>/brief.md`): blast radius, touched contracts, and open
questions. It SHALL NOT modify any file outside the change folder, and
open questions SHALL be recorded for human decision — the agent may not
resolve its own.

#### Scenario: Open question recorded not resolved
- **GIVEN** the brief finds an ambiguity the contract does not settle
- **WHEN** the brief is written
- **THEN** it appears under open questions, and /specify flags it as a
  stop condition rather than choosing an answer

### Requirement: Specify refuses ungated intake
The `/specify` command SHALL require an approved intake.md before writing
`changes/<slug>/spec.md`, and the produced delta SHALL pass
`scripts/validate-spec.sh` — requirements with GIVEN/WHEN/THEN scenarios,
properties with stated domains.

#### Scenario: Ungated change refused
- **GIVEN** a change whose intake.md has approved_by PENDING
- **WHEN** /specify runs
- **THEN** it stops, naming the missing approval

#### Scenario: Delta is validator-green on completion
- **GIVEN** an approved intake
- **WHEN** /specify completes
- **THEN** `bash scripts/validate-spec.sh` exits zero including the new
  delta

### Requirement: Plan budgets and routes decisions
The `/plan` command SHALL write `changes/<slug>/plan.md` — design
decisions with rejected alternatives, size counts, the line budget
(added lines vs merge-base, excluding `changes/**`, `specs/**`, `*.md`),
and numbered tasks each ending in a verify verb. Constraining decisions
SHALL be routed to an ADR instead of living in the plan.

#### Scenario: Budget declared
- **GIVEN** a completed plan
- **WHEN** it is reviewed
- **THEN** it states max files, added-line ceiling, and task count

#### Scenario: Rejected alternative recorded
- **GIVEN** a design decision with a credible alternative
- **WHEN** the plan is written
- **THEN** the alternative and the reason for rejection appear

### Requirement: Property — every command checks its upstream
For ANY workflow command with an upstream artifact, the command SHALL
verify the artifact exists and is approved before doing its own work; a
missing or PENDING upstream is a stop condition naming what is missing.

#### Scenario: Chaining audit
- **GIVEN** all four commands installed
- **WHEN** each is invoked with its upstream artifact absent or
  unapproved
- **THEN** each refuses with a message naming the artifact and the gate
  it lacks
