---
name: tdd:execute
description: Execute TEST-PLAN.md with strict RED-GREEN-REFACTOR TDD
argument-hint: "[--resume]"
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
Execute the test plan at `.tdd/TEST-PLAN.md` using strict TDD.

For each task in the plan:
1. **RED** — Write failing tests from the Given-When-Then specs
2. **GREEN** — Implement minimal code to pass
3. **REFACTOR** — Clean up if needed

Each phase gets its own atomic commit. Progress tracked in `.tdd/state.json` so execution can be resumed.

**Prerequisite:** Run `/tdd:plan` first to create TEST-PLAN.md.
</objective>

<execution_context>
@workflows/execute-tdd.md
@references/anti-patterns.md
</execution_context>

<context>
Arguments: $ARGUMENTS

@.tdd/TEST-PLAN.md
@.tdd/state.json
</context>

<process>
Execute the execute-tdd workflow from @workflows/execute-tdd.md end-to-end.
Preserve all workflow gates (plan loading, state tracking, RED-GREEN-REFACTOR cycle, error handling, verification).
</process>
