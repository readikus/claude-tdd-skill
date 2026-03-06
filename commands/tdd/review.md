---
name: tdd:review
description: Audit existing tests for anti-patterns, bad practices, and coverage gaps
argument-hint: "[path]"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - Write
  - Task
---
<objective>
Analyze existing test suites against 16 named anti-patterns and identify coverage gaps. Produces an actionable review report with line-specific findings and refactoring suggestions.

**Arguments:**
- Path (e.g., `src/`) → review tests under that path
- No argument → review all tests in project

**Output:** `.tdd/TEST-REVIEW.md` with severity-rated findings, coverage gaps, and recommended actions.

Does NOT fix tests — analyzes and reports. You decide what to act on.
</objective>

<execution_context>
@workflows/review-tests.md
@references/anti-patterns.md
</execution_context>

<context>
Arguments: $ARGUMENTS
</context>

<process>
Execute the review-tests workflow from @workflows/review-tests.md end-to-end.
Preserve all workflow gates (scope detection, agent spawn, finding presentation).
</process>
