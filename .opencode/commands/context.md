---
description: "Context — stage 1: read-only brief with blast radius and open questions"
---

# /context — the read-only survey before specifying

Input: `$ARGUMENTS` — the change slug. Produces
`changes/<slug>/brief.md` and modifies nothing else. Required from T2
upward (tier recorded in `intake.md`).

## Procedure

1. **Check upstream.** `changes/<slug>/intake.md` must exist and its
   `approved_by` must not be PENDING. If missing or unapproved, STOP and
   name the gate it lacks.
2. **Survey, read-only.** Identify: the files and directories this change
   likely touches (blast radius); which contracts govern them
   (`AGENTS.md`, `docs/sdlc.md`, `specs/**`); what the living spec tree
   already says about the capability, if anything.
3. **Record open questions.** Every ambiguity the contracts do not settle
   becomes a numbered open question. You may NOT resolve your own open
   questions — each is a stop condition for `/specify` until a human
   answers it.
4. **Write `changes/<slug>/brief.md`:**

   ```
   blast_radius: paths this change likely touches
   contracts: the rules that bind this change
   relevant_specs: living spec nodes that apply
   open_questions: numbered; each states what its answer would change
   ```

## Guardrails

- Read-only outside the change folder.
- "I'll assume X" is a bug: it becomes an open question.
