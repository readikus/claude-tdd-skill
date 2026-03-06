---
name: tdd:review
description: Audit existing tests for anti-patterns, bad practices, and coverage gaps
argument-hint: "[path | phase-number]"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - Write
  - Task
---
<objective>
Analyze existing test suites for anti-patterns (The Liar, The Mockery, The Inspector, etc.), bad practices, and coverage gaps. Produces an actionable review report with line-specific findings and refactoring suggestions.

**Modes:**
- **Path mode** — `/tdd:review src/` → review all tests under that path
- **Phase mode** — `/tdd:review 3` → review tests created during GSD phase 3
- **No argument** — review all tests in the project

**Output:** TEST-REVIEW.md with severity-rated findings, coverage gaps, and recommended actions.

**Does NOT fix tests** — it analyzes and reports. You decide what to act on.
</objective>

<execution_context>
@workflows/review-tests.md
@references/anti-patterns.md
</execution_context>

<context>
Arguments: $ARGUMENTS

@.planning/STATE.md
</context>

<process>
Execute the review-tests workflow from @workflows/review-tests.md end-to-end.
Preserve all workflow gates (scope detection, reference loading, agent spawn, presentation).
</process>
