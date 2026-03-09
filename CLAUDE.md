# TDD Skill for Claude Code

## What This Is
A standalone Claude Code skill for TDD — plan tests from requirements, execute test-first, audit for anti-patterns. No GSD dependency.

## Architecture

```
commands/tdd/        # User-facing /tdd:* slash commands (plan, execute, review, help)
agents/              # Agent prompts spawned by workflows
  tdd-planner.md     # Analyzes requirements → TEST-PLAN.md
  tdd-reviewer.md    # Audits tests → TEST-REVIEW.md
workflows/           # Orchestration logic (mode detection, agent spawning, state)
  plan-tests.md      # /tdd:plan workflow
  execute-tdd.md     # /tdd:execute workflow (RED-GREEN-REFACTOR engine)
  review-tests.md    # /tdd:review workflow
templates/           # TEST-PLAN.md structure template
references/          # Anti-patterns catalog (16 named patterns with severity)
install.sh           # Clone + symlink installer
```

## Key Concepts

- **TEST-PLAN.md** is the single artifact — contains both test specs (Given-When-Then) and implementation tasks. No separate plan document.
- **`.tdd/`** directory in user's project holds TEST-PLAN.md, state.json (execution progress), and TEST-REVIEW.md.
- **Two modes:** Linear (fetches task via MCP, posts clarification comments) and Standalone (analyzes code path or user description).
- **Install pattern:** `git clone` to `~/.tdd-skill/repo`, symlink `commands/tdd` into `~/.claude/commands/tdd`.

## Status / Next Steps

- Core skill files complete and pushed to GitHub (readikus/claude-tdd-skill)
- **Needs testing** with a real project — run /tdd:plan, /tdd:execute, /tdd:review end-to-end
- **Linear MCP** not yet tested — need a Linear MCP server configured to validate that mode
- Consider adding a `.gitignore` for `.tdd/state.json` (ephemeral) while keeping TEST-PLAN.md and TEST-REVIEW.md tracked
- The `@workflows/` and `@references/` paths in command files are relative — they work when symlinked but may need absolute paths if the skill is loaded differently
- Could add `/tdd:update` command (like progress has) for self-updating
