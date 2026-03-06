---
name: tdd:execute
description: Execute a GSD phase with TDD enforcement — tests written before implementation
argument-hint: "<phase-number> [--gaps-only]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion
---
<objective>
Wrap GSD's execute-phase to enforce test-first development. For each plan in the phase, the executor receives test specifications from TEST-PLAN.md and must write failing tests BEFORE implementing.

**Prerequisite:** TEST-PLAN.md must exist for the phase. Run `/tdd:plan {phase}` first.

**What changes vs standard execute-phase:**
1. TEST-PLAN.md test specs injected into executor context per plan
2. Executor writes failing tests first (RED), then implements (GREEN), then refactors
3. Commit order enforced: test → feat → refactor
4. TDD compliance verified after each plan
5. TDD metrics included in phase summary

**What stays the same:** Wave execution, parallelization, checkpoints, state updates, verification — all standard GSD behavior.
</objective>

<execution_context>
@workflows/execute-tdd.md
@~/.claude/get-shit-done/workflows/execute-phase.md
@~/.claude/get-shit-done/references/tdd.md
</execution_context>

<context>
Phase: $ARGUMENTS

**Flags:**
- `--gaps-only` — Execute only gap closure plans (inherited from GSD)

@.planning/ROADMAP.md
@.planning/STATE.md
</context>

<process>
Execute the execute-tdd workflow from @workflows/execute-tdd.md end-to-end.
This workflow wraps the standard execute-phase workflow — all GSD gates preserved, TDD enforcement added.
</process>
