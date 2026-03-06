# TDD Skill for Claude Code

A Claude Code skill for workshop-style TDD test planning, test-first execution, and test suite auditing. Integrates with [GSD](https://github.com/get-shit-done/gsd) phases and Linear tasks.

## What It Does

**Plan** — Analyzes requirements (from GSD phases, Linear tasks, or code) and produces a TEST-PLAN.md with Given-When-Then test specifications, implementation order, and anti-pattern guards.

**Execute** — Wraps GSD's execute-phase to enforce test-first development. Tests are written and committed before implementation code.

**Review** — Audits existing test suites against 16 anti-patterns (The Liar, The Mockery, The Inspector, etc.) and identifies coverage gaps.

## Install

```bash
./install.sh
```

This copies the skill files into `~/.claude/` where Claude Code can discover them.

## Commands

| Command | Description |
|---------|-------------|
| `/tdd:plan [target]` | Create test plan from requirements |
| `/tdd:execute [phase]` | Execute GSD phase with TDD enforcement |
| `/tdd:review [path]` | Audit existing tests for anti-patterns |
| `/tdd:help` | Usage guide |

## Modes

### GSD Integration

```
/gsd:plan-phase 3     →  Creates PLAN.md (what to build)
/tdd:plan 3           →  Creates TEST-PLAN.md (what to test)
/tdd:execute 3        →  Executes with TDD (tests before code)
/tdd:review 3         →  Audits test quality
```

The test plan slots between planning and execution. During `/tdd:execute`, the GSD executor receives test specifications and must commit failing tests before writing implementation code.

### Linear Integration

```
/tdd:plan ENG-123             →  Reads task, detects ambiguities
                                  Posts clarification questions to Linear
(PM answers on Linear)
/tdd:plan ENG-123             →  Re-run: picks up answers, finalizes plan
/tdd:plan ENG-123 --phase 3   →  Maps Linear task to GSD phase
```

When requirements are ambiguous, the skill posts specific clarification questions as comments on the Linear task so the product manager can respond.

Requires a [Linear MCP server](https://github.com/modelcontextprotocol/servers) configured in Claude Code settings.

### Standalone

```
/tdd:plan src/auth     →  Analyzes existing code, creates test plan
/tdd:review src/auth   →  Audits existing tests
```

Works on any codebase without GSD or Linear — just point it at a path.

## Artifacts

| File | Location | Created By |
|------|----------|------------|
| TEST-PLAN.md | `.planning/phases/XX-name/` (GSD) or project root | `/tdd:plan` |
| TEST-REVIEW.md | Same as above | `/tdd:review` |

### TEST-PLAN.md Structure

- **Requirements Source** — Where the requirements came from
- **Ambiguities** — Unclear requirements needing clarification
- **Testing Strategy** — Approach, pyramid, framework
- **Test Specifications** — Given-When-Then for each behavior
- **Implementation Order** — Dependency-ordered test groups
- **Anti-Pattern Guards** — Specific patterns to avoid for this feature

### TEST-REVIEW.md Structure

- **Summary** — Severity counts and overall health
- **Findings** — Line-specific issues with suggested fixes
- **Coverage Gaps** — Untested source files and functions
- **Good Practices** — What's done well (preserved during refactoring)
- **Recommended Actions** — Prioritized fix list

## Anti-Patterns Detected

| Pattern | Severity | Description |
|---------|----------|-------------|
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

## File Structure

```
claude-tdd-skill/
├── commands/tdd/        # User-facing /tdd:* commands
│   ├── plan.md
│   ├── execute.md
│   ├── review.md
│   └── help.md
├── agents/              # Agent definitions
│   ├── tdd-planner.md   # Produces TEST-PLAN.md
│   └── tdd-reviewer.md  # Produces TEST-REVIEW.md
├── workflows/           # Orchestration logic
│   ├── plan-tests.md
│   ├── execute-tdd.md
│   └── review-tests.md
├── templates/           # Output templates
│   └── test-plan.md
├── references/          # Reference materials
│   └── anti-patterns.md
├── install.sh
└── README.md
```
