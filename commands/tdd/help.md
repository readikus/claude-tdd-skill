---
name: tdd:help
description: Show available TDD commands and usage guide
---
<objective>
Display TDD skill commands, modes, and workflow overview.
</objective>

<process>
Output this markdown directly:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 TDD Skill — Commands
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Commands

| Command | Description |
|---------|-------------|
| `/tdd:plan [target]` | Create test plan from requirements |
| `/tdd:execute` | Execute test plan with RED-GREEN-REFACTOR |
| `/tdd:review [path]` | Audit existing tests for anti-patterns |
| `/tdd:help` | This help page |

## /tdd:plan Modes

| Argument | Mode | Example |
|----------|------|---------|
| Linear ID | Linear task | `/tdd:plan ENG-123` |
| File path | Code analysis | `/tdd:plan src/auth` |
| Description | New feature | `/tdd:plan "email validation"` |
| (none) | Current directory | `/tdd:plan` |

## Workflow

```
Requirements ──► /tdd:plan ──► .tdd/TEST-PLAN.md
                                    │
                                    ▼
                            /tdd:execute ──► RED-GREEN-REFACTOR
                                    │         per task
                                    ▼
                            /tdd:review ──► .tdd/TEST-REVIEW.md
```

## With Linear

```
/tdd:plan ENG-123         →  Reads task, posts clarification questions
(PM answers on Linear)
/tdd:plan ENG-123         →  Re-run: picks up answers, finalizes plan
/tdd:execute              →  RED-GREEN-REFACTOR per task
/tdd:review               →  Verify test quality
```

## Standalone

```
/tdd:plan src/auth        →  Analyzes code, creates test plan
/tdd:execute              →  Write tests first, then implement
/tdd:review               →  Audit test quality
```

## New Feature from Description

```
/tdd:plan "user registration with email verification"
/tdd:execute              →  Write tests first, then implement
/tdd:review               →  Verify test quality
```

## Files

```
.tdd/
  TEST-PLAN.md            # Test specs + implementation tasks
  state.json              # Execution progress (resume support)
  TEST-REVIEW.md          # Anti-pattern audit results
```

## RED-GREEN-REFACTOR Cycle

For each task in the test plan:

1. **RED** — Write failing tests from Given-When-Then specs
   Commit: `test: add failing tests for {task}`

2. **GREEN** — Write minimal code to pass all tests
   Commit: `feat: implement {task}`

3. **REFACTOR** — Clean up if needed (tests must still pass)
   Commit: `refactor: clean up {task}`

## Anti-Patterns Detected by /tdd:review

| Pattern | Severity | What It Is |
|---------|----------|------------|
| The Liar | Critical | Tests that pass but verify nothing |
| The Freeloader | Critical | Tests with no assertions |
| Happy Path Only | Critical | Missing error/edge case tests |
| The Inspector | High | Testing implementation, not behavior |
| The Mockery | High | Over-mocking everything |
| The Secret Catcher | High | Shared mutable state between tests |
| The Giant | High | Tests verifying too many things |
| The Ice Cream Cone | High | Inverted testing pyramid |
| The Slow Poke | Medium | Unnecessarily slow tests |
| The Nitpicker | Medium | Over-specifying irrelevant details |
| The Dead Tree | Low | Commented-out/skipped tests |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
</process>
