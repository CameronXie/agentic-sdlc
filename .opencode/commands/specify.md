---
description: "Specify — stage 2: the scenario delta, validator-green"
---

# /specify — the change's acceptance contract

Input: `$ARGUMENTS` — the change slug. Writes `changes/<slug>/spec.md`
from the approved intake. The delta is the acceptance contract: every
scenario becomes one table test with the scenario name in the `t.Run`
name; every property becomes a fuzz test whose input guard is its stated
domain.

## Procedure

1. **Check upstream.** `intake.md` must be approved (not PENDING). If the
   change is T2+, `brief.md` must exist and its open questions must be
   answered or empty — unanswered ones STOP you; name them.
2. **Write the delta** (`# Spec Delta — <capability>`):
   - `### Requirement:` blocks, each with at least one
     `#### Scenario:` containing **GIVEN**, **WHEN**, and **THEN** lines.
   - Property requirements state their domain ("For ANY \<domain\>, …")
     and also carry a scenario.
   - Requirements assert behavior, never implementation.
   - Any requirement pinning framework behavior cites a repro (command +
     observed output) captured in the plan — never pin from memory.
3. **Validate until green:** `bash scripts/validate-spec.sh`.
4. **Stop.** The human approves intent — spec + plan together — at
   stage 4. Do not begin implementation.

## Guardrails

- No scenario without GIVEN, WHEN, and THEN (the validator enforces it).
- No property without a stated domain.
- Nothing outside the intake's `non_goals` boundary — scope creep stops
  here and goes back to intake.
