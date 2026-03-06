<purpose>
Execute a TEST-PLAN.md using strict RED-GREEN-REFACTOR TDD. For each task in the plan: write failing tests first, implement to pass, refactor. Track progress in .tdd/state.json.
</purpose>

<core_principle>
TEST-PLAN.md is the single source of truth. Every implementation task starts with failing tests derived from the plan's Given-When-Then specs. No code is written without a failing test first.
</core_principle>

<prerequisite>
TEST-PLAN.md must exist at `.tdd/TEST-PLAN.md`. If not:
```
No test plan found.

Run /tdd:plan first to create one.
```
Exit.
</prerequisite>

<process>

<step name="initialize" priority="first">
Load test plan and state:

```bash
# Validate test plan exists
if [ ! -f .tdd/TEST-PLAN.md ]; then
  echo "No test plan found at .tdd/TEST-PLAN.md"
  exit 1
fi

# Load or create state
if [ ! -f .tdd/state.json ]; then
  echo '{"status":"not_started","current_task":0,"tasks":[],"commits":[]}' > .tdd/state.json
fi
```

Read TEST-PLAN.md:
- Parse frontmatter for status, framework, source info
- If status is `draft`: warn about unresolved ambiguities, ask to proceed or abort
- Extract all tasks (from `<task>` blocks)
- Extract test specs per task
- Extract anti-pattern guards

Read state.json:
- If resuming: skip completed tasks, start from current_task
- Display what's already done
</step>

<step name="check_test_infrastructure">
Before first task, ensure test framework is ready:

```bash
# Node.js
if [ -f package.json ]; then
  if ! npm test -- --passWithNoTests 2>/dev/null; then
    echo "Test framework needs setup"
  fi
fi

# Python
if [ -f pyproject.toml ] || [ -f requirements.txt ]; then
  python -m pytest --co -q 2>/dev/null || echo "pytest needs setup"
fi

# Go — built-in, always available
# Rust — built-in via cargo test
```

If framework missing: install it as part of first task (not a separate step).
</step>

<step name="execute_tasks">
For each task in TEST-PLAN.md:

Display:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 TDD ► Task {N}/{total}: {task name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### RED — Write Failing Tests

1. Read the test specs for this task from TEST-PLAN.md
2. Create the test file at the path specified in the task
3. Write test cases matching the Given-When-Then specs:
   - Each spec becomes one test
   - Use descriptive names from the spec
   - Follow project conventions for test file location and naming
4. Run tests — they **MUST fail**
   ```bash
   # Run only the new test file
   npm test -- {test_file} 2>&1
   # or: pytest {test_file} -v 2>&1
   # or: go test -run {pattern} -v 2>&1
   ```
5. If tests PASS: the behavior already exists — investigate. Either:
   - The test isn't testing what it claims (fix the test)
   - The feature already exists (skip, note in state)
6. Commit failing tests:
   ```bash
   git add {test_file}
   git commit -m "test: add failing tests for {task name}

   - {spec 1 name}
   - {spec 2 name}
   - {spec N name}
   "
   ```
7. Record commit in state.json

### GREEN — Implement to Pass

1. Read the implementation guidance from the task's `<implement>` block
2. Create or modify the source file at the path specified
3. Write **minimal** code to make ALL tests pass
   - No cleverness, no optimization — just make it work
   - Don't add features not covered by tests
4. Run tests — they **MUST pass**
   ```bash
   npm test -- {test_file} 2>&1
   ```
5. If tests FAIL: debug and iterate. Do not move on until green.
6. Also run the full test suite to check for regressions:
   ```bash
   npm test 2>&1
   ```
7. Commit implementation:
   ```bash
   git add {source_file} {any supporting files}
   git commit -m "feat: implement {task name}

   - {what was implemented}
   - All {N} tests passing
   "
   ```
8. Record commit in state.json

### REFACTOR — Clean Up (if needed)

1. Look at the implementation. Is there obvious duplication, complexity, or smell?
2. If YES:
   - Refactor the code
   - Run tests — they **MUST still pass**
   - Commit:
     ```bash
     git commit -m "refactor: clean up {task name}

     - {what was improved}
     - All tests still passing
     "
     ```
3. If NO: skip refactor, move to next task

### Update State

After each task completes:
```bash
# Update state.json
node -e "
const s = require('./.tdd/state.json');
s.current_task = {NEXT_TASK_INDEX};
s.tasks.push({
  name: '{task_name}',
  status: 'completed',
  test_commit: '{test_hash}',
  feat_commit: '{feat_hash}',
  refactor_commit: '{refactor_hash_or_null}',
  specs_count: {N},
  completed_at: new Date().toISOString()
});
s.commits.push('{test_hash}', '{feat_hash}');
require('fs').writeFileSync('.tdd/state.json', JSON.stringify(s, null, 2));
"
```

</step>

<step name="handle_errors">

**Test won't fail in RED phase:**
- Check: is the test actually asserting the right thing?
- Check: does the behavior already exist from a prior task?
- If feature exists: mark as "already implemented" in state, skip to next task
- If test is wrong: fix the test, re-run

**Test won't pass in GREEN phase:**
- Debug the implementation
- Read the error output carefully
- If stuck after 3 iterations: ask the user for guidance

**Tests break in REFACTOR phase:**
- Undo the refactor: `git checkout -- {files}`
- The GREEN state was correct — keep it
- Note in state that refactor was attempted but reverted

**Unrelated tests break:**
- Stop and investigate — may indicate coupling
- Fix before proceeding (this is a legitimate bug found by TDD)
- Commit the fix separately: `fix: resolve {issue} found during TDD`

</step>

<step name="verify_completion">
After all tasks complete:

1. Run full test suite:
   ```bash
   npm test 2>&1
   # or equivalent
   ```

2. Verify all tests pass

3. Check anti-pattern guards from TEST-PLAN.md:
   - Were any guards violated during implementation?
   - Note any concerns

4. Update state.json:
   ```json
   {
     "status": "complete",
     "completed_at": "...",
     "total_tests": N,
     "total_commits": M,
     "all_passing": true
   }
   ```
</step>

<step name="present_results">
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 TDD ► EXECUTION COMPLETE ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Tasks:** {completed}/{total}
**Tests written:** {N}
**All passing:** ✓

### TDD Cycle Summary

| Task | Test Commit | Feat Commit | Refactor | Specs |
|------|------------|-------------|----------|-------|
| {name} | {hash} | {hash} | {hash|-} | {N} |

### Commits

{chronological list of all commits}

───────────────────────────────────────────────────────

## ▶ Next

/tdd:review — audit test quality against anti-patterns

───────────────────────────────────────────────────────
```
</step>

</process>

<resumption>
If `/tdd:execute` is run again after a partial execution:

1. Read `.tdd/state.json`
2. Display completed tasks
3. Resume from `current_task`
4. Skip already-completed tasks (verify their commits exist: `git log --oneline | grep {hash}`)
</resumption>

<commit_conventions>
All commits follow conventional commits:

| Phase | Format |
|-------|--------|
| RED | `test: add failing tests for {task name}` |
| GREEN | `feat: implement {task name}` |
| REFACTOR | `refactor: clean up {task name}` |
| Bug found | `fix: resolve {issue} found during TDD` |
| Framework setup | `chore: configure {framework} for testing` |

Stage files individually — never `git add .` or `git add -A`.
</commit_conventions>
