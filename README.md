<div align="center">

# TDD Skill

**Test planning, test-first execution, and test suite auditing for Claude Code.**

**Plan tests from requirements. Write them before code. Catch anti-patterns.**

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
/tdd:review src/                # audit existing tests for anti-patterns
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

Writing tests after the code is done is like proofreading after you've hit send. You end up testing what you built rather than what you should have built. The tests mirror the implementation instead of challenging it, edge cases get missed, and the whole suite becomes brittle — tightly coupled to how things work today, not what they're supposed to do.

TDD Skill is a Claude Code skill that flips this around. It reads your requirements — from GSD phase plans, Linear tasks, or existing code — and produces a test plan with Given-When-Then specifications before any implementation starts. When you execute, tests are written and committed first. And when you want to audit what's already there, it checks against 16 named anti-patterns so you know exactly what to fix.

---

## Commands

| Command | What it does |
|---------|--------------|
| `/tdd:plan [target]` | Create test plan from requirements |
| `/tdd:execute [phase]` | Execute GSD phase with TDD enforcement |
| `/tdd:review [path]` | Audit existing tests for anti-patterns |
| `/tdd:help` | Usage guide |

---

### `/tdd:plan`

Analyzes requirements and produces a TEST-PLAN.md with test specifications, implementation order, and anti-pattern guards.

**Auto-detects mode from the argument:**

| Argument | Mode | Example |
|----------|------|---------|
| Phase number | GSD phase | `/tdd:plan 3` |
| Linear ID | Linear task | `/tdd:plan ENG-123` |
| File path | Standalone | `/tdd:plan src/auth` |
| (none) | Auto-detect | `/tdd:plan` |
| Linear + Phase | Combined | `/tdd:plan ENG-123 --phase 3` |

**GSD mode** reads your PLAN.md files and derives test specs from plan objectives, must_haves, and task done-criteria.

**Linear mode** fetches the task from Linear. If requirements are ambiguous, it posts clarification questions as comments on the task so the PM can respond. The test plan stays in `draft` status until clarified. Requires a [Linear MCP server](https://github.com/modelcontextprotocol/servers) configured in Claude Code.

**Standalone mode** analyzes existing code, detects testable exports, identifies coverage gaps, and generates a test plan.

---

### `/tdd:execute`

Wraps GSD's `/gsd:execute-phase` to enforce test-first development.

```
/tdd:execute 3                 # Execute phase 3 with TDD
/tdd:execute 3 --gaps-only     # Execute only gap closure plans
```

For each plan in the phase:
1. **RED** — Write failing tests from TEST-PLAN.md specs, commit: `test(03-01): ...`
2. **GREEN** — Implement to pass, commit: `feat(03-01): ...`
3. **REFACTOR** — Clean up if needed, commit: `refactor(03-01): ...`

Everything else — wave execution, parallelization, checkpoints, state updates — works exactly like standard GSD. TDD compliance is verified after each plan.

**Prerequisite:** Run `/tdd:plan` first to create TEST-PLAN.md.

---

### `/tdd:review`

Audits existing test suites against 16 named anti-patterns and identifies coverage gaps.

```
/tdd:review                    # All tests in project
/tdd:review src/               # Tests under a path
/tdd:review 3                  # Tests from GSD phase 3
```

Output:
```
TDD > REVIEW COMPLETE

Scope: 24 test files, 31 source files
Health: needs attention

| Severity | Count |
|----------|-------|
| Critical | 2     |
| High     | 5     |
| Medium   | 8     |
| Low      | 3     |

Top Issues:
1. src/auth.test.ts:45 — The Liar (assertions always true)
2. src/api/users.test.ts:12 — The Mockery (17 mocks, 3 assertions)
3. src/utils/validate.test.ts — Happy Path Only (no error cases)
```

Full report written to TEST-REVIEW.md with line-specific findings and suggested fixes.

---

## Workflow

### With GSD

```
/gsd:plan-phase 3      # Creates PLAN.md (what to build)
/tdd:plan 3            # Creates TEST-PLAN.md (what to test)
/tdd:execute 3         # Executes with TDD (tests before code)
/tdd:review 3          # Audits test quality
```

### With Linear

```
/tdd:plan ENG-123              # Reads task, posts clarification questions
(PM answers on Linear)
/tdd:plan ENG-123              # Re-run: picks up answers, finalizes plan
/tdd:plan ENG-123 --phase 3    # Maps to GSD phase
/tdd:execute 3                 # Executes with TDD
```

### Standalone

```
/tdd:plan src/auth      # Analyzes code, creates test plan
/tdd:review src/auth    # Audits existing tests
```

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

## Artifacts

| File | Location | Created by |
|------|----------|------------|
| TEST-PLAN.md | `.planning/phases/XX-name/` (GSD) or project root | `/tdd:plan` |
| TEST-REVIEW.md | Same as above | `/tdd:review` |

### TEST-PLAN.md

- **Requirements Source** — where the requirements came from
- **Ambiguities** — unclear requirements needing clarification
- **Testing Strategy** — approach, pyramid, framework choice
- **Test Specifications** — Given-When-Then for each behavior
- **Implementation Order** — dependency-ordered test groups
- **Anti-Pattern Guards** — specific patterns to avoid for this feature

### TEST-REVIEW.md

- **Summary** — severity counts and overall health rating
- **Findings** — line-specific issues with suggested fixes
- **Coverage Gaps** — untested source files and functions
- **Good Practices** — what's done well (so you don't break it)
- **Recommended Actions** — prioritized fix list

---

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- Git
- [GSD](https://github.com/gsd-build/get-shit-done) — optional, for phase integration
- [Linear MCP](https://github.com/modelcontextprotocol/servers) — optional, for Linear task integration

---

<div align="center">

**Write the test first. Then make it pass.**

</div>
