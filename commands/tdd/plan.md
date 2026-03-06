---
name: tdd:plan
description: Create a TDD test plan from Linear task, code analysis, or feature description
argument-hint: "[LINEAR-ID | path | description]"
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
Analyze requirements and produce a TEST-PLAN.md — the single source of truth for what to test and what to build. Contains Given-When-Then test specifications and implementation tasks.

**Modes (auto-detected from argument):**
- **Linear mode** — Linear ID (e.g., `ENG-123`) → fetch task, analyze requirements, post clarifications if ambiguous
- **Standalone mode** — path (e.g., `src/auth`) → analyze existing code for coverage gaps
- **Standalone mode** — description (e.g., `"email validation service"`) → derive tests from requirements
- **No argument** — analyze current directory

**Output:** `.tdd/TEST-PLAN.md` with test specs, implementation tasks, and anti-pattern guards
</objective>

<execution_context>
@workflows/plan-tests.md
@references/anti-patterns.md
@templates/test-plan.md
</execution_context>

<context>
Arguments: $ARGUMENTS
</context>

<process>
Execute the plan-tests workflow from @workflows/plan-tests.md end-to-end.
Preserve all workflow gates (mode detection, context loading, agent spawn, ambiguity handling, routing).
</process>
