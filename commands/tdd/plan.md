---
name: tdd:plan
description: Create a TDD test plan from GSD phase, Linear task, or codebase analysis
argument-hint: "[phase-number | LINEAR-ID | path] [--phase N]"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Task
  - WebFetch
  - AskUserQuestion
  - mcp__linear__*
---
<objective>
Analyze requirements and produce a TEST-PLAN.md defining what tests to write, in what order, with anti-pattern guards.

**Modes (auto-detected from argument):**
- **GSD mode** — phase number (e.g., `3`) → analyze PLAN.md files → TEST-PLAN.md in phase dir
- **Linear mode** — Linear ID (e.g., `ENG-123`) → analyze task → TEST-PLAN.md, post clarifications to Linear
- **Standalone mode** — path (e.g., `src/auth`) → analyze code → TEST-PLAN.md
- **No argument** — auto-detect: GSD if `.planning/` exists, else standalone on current dir

**Linear + GSD combo:** `/tdd:plan ENG-123 --phase 3` → fetch Linear task, map to GSD phase

**Output:** TEST-PLAN.md with Given-When-Then specs, implementation order, and anti-pattern guards
</objective>

<execution_context>
@workflows/plan-tests.md
@references/anti-patterns.md
@templates/test-plan.md
</execution_context>

<context>
Arguments: $ARGUMENTS

@.planning/ROADMAP.md
@.planning/STATE.md
</context>

<process>
Execute the plan-tests workflow from @workflows/plan-tests.md end-to-end.
Preserve all workflow gates (mode detection, context loading, agent spawn, ambiguity handling, routing).
</process>
