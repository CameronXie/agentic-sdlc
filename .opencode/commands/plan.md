---
description: "Plan — stage 3: design with rejected alternatives, budget, verify-verb tasks"
---

# /plan — how, with the receipts to prove it

Input: `$ARGUMENTS` — the change slug. Writes `changes/<slug>/plan.md`
from the approved intake and validator-green spec.

## Procedure

1. **Check upstream.** `intake.md` approved; `spec.md` passes
   `bash scripts/validate-spec.sh`. Otherwise STOP and name what is
   missing.
2. **Design decisions, each with rejected alternatives** and the reason
   one was chosen. A decision that constrains *future* changes is routed
   to `docs/adr/<n>-<slug>.md` — it must outlive this change, not live in
   its plan.
3. **Declare the budget:** max files, added-line ceiling, task count. The
   line budget counts additions vs merge-base with main, excluding
   `changes/**`, `specs/**`, and `*.md`. Exceeding it later is a
   specification error, not permission to continue.
4. **Tasks:** numbered checkboxes, one concept each, each ending in a
   verify verb and naming the evidence kind it will produce — gate output
   once the gate exists, named tool output before. Order tests first: the
   scenario's failing test is written before its implementation.
5. **Stop for the human gate:** approve intent (spec + plan together).

## Guardrails

- Every task traces to a requirement; a task with no requirement is scope
  creep.
- No task mixes feature work with gate work.
