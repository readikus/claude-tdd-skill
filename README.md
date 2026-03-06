<div align="center">

# TDD Skill

**Test-driven development for Claude Code — plan tests from requirements, write them before code, catch anti-patterns.**

**Lightweight TDD workflow with Linear integration.**

[![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)](LICENSE)

</div>

---

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/readikus/claude-tdd-skill/main/install.sh | bash
```

Restart Claude Code, then:

```
/tdd:plan src/                  # create test plan from existing code
/tdd:execute                    # RED-GREEN-REFACTOR per task
/tdd:review                     # audit test quality
```

<details>
<summary><strong>Manual install / Update / Uninstall</strong></summary>

**Manual install:**
```bash
git clone https://github.com/readikus/claude-tdd-skill.git ~/.tdd-skill/repo
ln -sfn ~/.tdd-skill/repo/commands/tdd ~/.claude/commands/tdd
```

**Update:**
```bash
curl -fsSL https://raw.githubusercontent.com/readikus/claude-tdd-skill/main/install.sh | bash
```

**Uninstall:**
```bash
rm -rf ~/.claude/commands/tdd ~/.tdd-skill
```

</details>

---

## Why

Writing tests after the code is done is like proofreading after you've hit send. You end up testing what you built rather than what you should have built — tests mirror the implementation instead of challenging it, edge cases get missed, and the suite becomes brittle.

TDD Skill flips this. It reads your requirements — from Linear tasks, existing code, or a plain description — and produces a test plan with Given-When-Then specifications before any implementation starts. When you execute, tests are written and committed first. When you review, it checks against 16 named anti-patterns so you know exactly what to fix.

No milestones. No roadmaps. No heavy project scaffolding. Just requirements → test plan → test-first execution.

---

## Commands

| Command | What it does |
|---------|--------------|
| `/tdd:plan [target]` | Create test plan from requirements |
| `/tdd:execute` | Execute plan with RED-GREEN-REFACTOR |
| `/tdd:review [path]` | Audit existing tests for anti-patterns |
| `/tdd:help` | Usage guide |

---

### `/tdd:plan`

Analyzes requirements and produces `.tdd/TEST-PLAN.md` — the single source of truth containing test specifications AND implementation tasks.

```
/tdd:plan ENG-123               # from Linear task
/tdd:plan src/auth               # from existing code
/tdd:plan "email validation"     # from description
/tdd:plan                        # current directory
```

**Linear mode** fetches the task, analyzes acceptance criteria, and derives test specs. If requirements are ambiguous, it posts clarification questions as comments on the task so the PM can respond. The plan stays in `draft` status until clarified. Requires the [Linear MCP server](https://linear.app/docs/mcp) configured in Claude Code.

**Standalone mode** analyzes existing code for testable exports and coverage gaps, or derives tests from a plain feature description.

---

### `/tdd:execute`

Executes `.tdd/TEST-PLAN.md` using strict RED-GREEN-REFACTOR.

```
/tdd:execute                     # run the test plan
/tdd:execute --resume            # resume from where you left off
```

For each task in the plan:
1. **RED** — Write failing tests from Given-When-Then specs, commit: `test: ...`
2. **GREEN** — Implement minimal code to pass, commit: `feat: ...`
3. **REFACTOR** — Clean up if needed, commit: `refactor: ...`

Progress is tracked in `.tdd/state.json` — you can resume after interruption.

---

### `/tdd:review`

Audits existing test suites against 16 named anti-patterns.

```
/tdd:review                      # all tests in project
/tdd:review src/                 # tests under a path
```

Output:
```
TDD ► REVIEW COMPLETE

Scope: 24 test files, 31 source files
Health: needs attention

| Severity | Count |
|----------|-------|
| Critical | 2     |
| High     | 5     |

Top Issues:
1. src/auth.test.ts:45 — The Liar (assertions always true)
2. src/api/users.test.ts:12 — The Mockery (17 mocks, 3 assertions)
3. src/utils/validate.test.ts — Happy Path Only (no error cases)
```

Full report written to `.tdd/TEST-REVIEW.md`.

---

## Workflow

### From Linear

```
/tdd:plan ENG-123         →  Reads task, posts clarification questions
(PM answers on Linear)
/tdd:plan ENG-123         →  Re-run: picks up answers, finalizes plan
/tdd:execute              →  RED-GREEN-REFACTOR per task
/tdd:review               →  Verify test quality
```

### From Existing Code

```
/tdd:plan src/auth        →  Analyzes code, finds coverage gaps
/tdd:execute              →  Write tests first, then implement
/tdd:review               →  Audit results
```

### From Description

```
/tdd:plan "user registration with email verification"
/tdd:execute              →  Write tests first, then implement
/tdd:review               →  Verify test quality
```

---

## Files

Everything lives in `.tdd/` in your project root:

```
.tdd/
  TEST-PLAN.md            # Test specs + implementation tasks (from /tdd:plan)
  state.json              # Execution progress — supports resume (from /tdd:execute)
  TEST-REVIEW.md          # Anti-pattern audit results (from /tdd:review)
```

### TEST-PLAN.md

The single artifact. Contains:
- **Requirements** — where they came from and what's clear vs ambiguous
- **Test Specifications** — Given-When-Then for each behavior
- **Implementation Tasks** — what to build to make each test group pass
- **Anti-Pattern Guards** — what to watch out for

### state.json

Tracks execution progress:
- Current task, completed tasks, commit hashes
- Allows `/tdd:execute --resume` after interruption

---

## Anti-Patterns Detected

| Pattern | Severity | What it is |
|---------|----------|------------|
| The Liar | Critical | Tests that pass but verify nothing meaningful |
| The Freeloader | Critical | Tests with no assertions |
| Happy Path Only | Critical | Only success cases tested |
| The Inspector | High | Testing implementation details, not behavior |
| The Mockery | High | Over-mocking — testing the mocking framework |
| The Secret Catcher | High | Shared mutable state between tests |
| The Giant | High | Single test verifying too many things |
| The Ice Cream Cone | High | Inverted testing pyramid |
| The Slow Poke | Medium | Unnecessarily slow unit tests |
| The Sequencer | Medium | Tests that depend on execution order |
| The Greedy Catcher | Medium | Overly broad exception catching |
| The Nitpicker | Medium | Asserting on irrelevant details |
| The Copy-Paste Plague | Medium | Duplicated test setup/assertions |
| The Dead Tree | Low | Commented-out or permanently skipped tests |
| The Loudmouth | Low | Noisy console output in tests |
| The Local Hero | Low | Tests that only pass on one machine |

---

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- Git
- [Linear MCP](https://linear.app/docs/mcp) — optional, for Linear task integration

---

<div align="center">

**Write the test first. Then make it pass.**

</div>
