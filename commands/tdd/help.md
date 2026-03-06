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

## Core Commands

| Command | Description |
|---------|-------------|
| `/tdd:plan [target]` | Create test plan from requirements |
| `/tdd:execute [phase]` | Execute phase with TDD enforcement |
| `/tdd:review [path]` | Audit existing tests for anti-patterns |
| `/tdd:help` | This help page |

## /tdd:plan Modes

| Argument | Mode | Example |
|----------|------|---------|
| Phase number | GSD phase | `/tdd:plan 3` |
| Linear ID | Linear task | `/tdd:plan ENG-123` |
| File path | Standalone | `/tdd:plan src/auth` |
| (none) | Auto-detect | `/tdd:plan` |
| Linear + Phase | Combined | `/tdd:plan ENG-123 --phase 3` |

## Workflow

```
Requirements ──► /tdd:plan ──► TEST-PLAN.md
                                    │
                                    ▼
                            /tdd:execute ──► Tests first, then code
                                    │
                                    ▼
                            /tdd:review ──► Verify test quality
```

**With GSD:**
```
/gsd:plan-phase 3     →  Creates PLAN.md (what to build)
/tdd:plan 3           →  Creates TEST-PLAN.md (what to test)
/tdd:execute 3        →  Executes with TDD (tests before code)
/tdd:review 3         →  Audits test quality
```

**With Linear:**
```
/tdd:plan ENG-123             →  Reads task, posts clarification questions
(PM answers on Linear)
/tdd:plan ENG-123             →  Re-run: picks up answers, finalizes plan
/tdd:plan ENG-123 --phase 3   →  Maps to GSD phase
/tdd:execute 3                →  Executes with TDD
```

**Standalone:**
```
/tdd:plan src/auth     →  Analyzes code, creates test plan
/tdd:review src/auth   →  Audits existing tests
```

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

## Key Concepts

**TEST-PLAN.md** — The artifact. Defines what to test using Given-When-Then specs, not how to implement. Lives alongside PLAN.md in phase directories.

**TDD Enforcement** — During /tdd:execute, the executor MUST commit failing tests before implementation. Commit order: `test()` → `feat()` → `refactor()`.

**Ambiguity Detection** — In Linear mode, unclear requirements are posted as clarification comments. The test plan stays in `draft` status until clarified.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
</process>
