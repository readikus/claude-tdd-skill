<purpose>
Wrap GSD's execute-phase to enforce test-first development. Reads TEST-PLAN.md alongside PLAN.md and injects test specifications into the executor context so tests are written before implementation.
</purpose>

<core_principle>
This workflow does NOT replace execute-phase — it wraps it. The key addition: for each plan in the phase, the executor receives the corresponding test specifications from TEST-PLAN.md and must write failing tests BEFORE implementing.
</core_principle>

<prerequisite>
TEST-PLAN.md must exist for the phase. If not:
```
⚠ No test plan found for Phase {X}.

Run /tdd:plan {X} first to create a test plan.
```
Exit.
</prerequisite>

<process>

<step name="initialize" priority="first">
Load context (same as execute-phase):

```bash
INIT=$(node ~/.claude/get-shit-done/bin/gsd-tools.js init execute-phase "${PHASE_ARG}")
```

Parse JSON for all standard execute-phase fields.

Additionally load TEST-PLAN.md:
```bash
TEST_PLAN=$(cat .planning/phases/${PHASE_DIR}/*-TEST-PLAN.md 2>/dev/null)
```

**Validate:**
- TEST-PLAN.md exists → proceed
- TEST-PLAN.md status is `confirmed` → proceed
- TEST-PLAN.md status is `draft` → warn: "Test plan has unresolved ambiguities. Proceed anyway? (tests for ambiguous specs will be skipped)"
- No TEST-PLAN.md → error, route to /tdd:plan
</step>

<step name="extract_test_specs_per_plan">
Parse TEST-PLAN.md to map test specifications to plans:

For each plan in the phase:
1. Find the corresponding section in TEST-PLAN.md (matched by plan number or feature name)
2. Extract:
   - Test file paths
   - Given-When-Then specifications
   - Edge cases
   - Anti-pattern guards relevant to this plan

Build a `test_context` block for each plan:

```markdown
<test_context>
## Test Specifications for Plan {XX-NN}

Before implementing ANY task in this plan, write failing tests first.

### Required Tests

**File:** `{test_file_path}`

1. `should {behavior}` — Given: {given}, When: {when}, Then: {then}
2. `should {behavior}` — Given: {given}, When: {when}, Then: {then}
3. `should handle {edge case}` — Given: {given}, When: {when}, Then: {then}

### Anti-Pattern Guards
- {specific guard for this plan}
- {specific guard for this plan}

### Execution Order
1. Write ALL failing tests above → commit: `test({phase}-{plan}): add failing tests for {feature}`
2. Implement to pass ALL tests → commit per task as normal
3. Refactor if needed → commit: `refactor({phase}-{plan}): clean up {feature}`
</test_context>
```
</step>

<step name="execute_waves_with_tdd">
Follow the standard execute-phase wave execution flow, but modify the executor spawn:

For each plan in a wave:

```
Task(
  subagent_type="gsd-executor",
  model="{executor_model}",
  prompt="
    <objective>
    Execute plan {plan_number} of phase {phase_number}-{phase_name} using TDD.
    Write failing tests FIRST, then implement. Commit each phase of TDD cycle atomically.
    </objective>

    <execution_context>
    @~/.claude/get-shit-done/workflows/execute-plan.md
    @~/.claude/get-shit-done/templates/summary.md
    @~/.claude/get-shit-done/references/tdd.md
    </execution_context>

    {test_context_for_this_plan}

    <tdd_enforcement>
    CRITICAL: This plan is being executed with TDD enforcement.

    For EACH task in this plan:

    1. **RED** — Before writing ANY implementation code:
       - Create the test file specified in test_context
       - Write the failing tests from the specifications above
       - Run tests — they MUST fail (if they pass, the behavior already exists — investigate)
       - Commit: test({phase}-{plan}): add failing tests for {feature}

    2. **GREEN** — Implement the task:
       - Write minimal code to make ALL tests pass
       - Run tests — they MUST pass
       - Commit: feat({phase}-{plan}): implement {feature}

    3. **REFACTOR** — If needed:
       - Clean up implementation
       - Run tests — they MUST still pass
       - Commit only if changes: refactor({phase}-{plan}): clean up {feature}

    If a test specification is ambiguous or impossible to write, note it as a deviation
    in the SUMMARY.md but DO NOT skip it silently.
    </tdd_enforcement>

    <files_to_read>
    Read these files at execution start:
    - Plan: {phase_dir}/{plan_file}
    - State: .planning/STATE.md
    - Config: .planning/config.json (if exists)
    </files_to_read>

    <success_criteria>
    - [ ] Failing tests committed BEFORE implementation
    - [ ] All tests passing after implementation
    - [ ] Each TDD cycle has separate commits (test → feat → refactor)
    - [ ] SUMMARY.md documents TDD cycle (RED/GREEN/REFACTOR for each feature)
    - [ ] STATE.md updated
    </success_criteria>
  "
)
```

All other wave execution logic (parallel/sequential, spot-checks, failure handling, checkpoints) follows the standard execute-phase workflow exactly.
</step>

<step name="verify_tdd_compliance">
After each plan completes, verify TDD was followed:

```bash
# Check for test commits before feat commits
git log --oneline --all | grep "${PHASE}-${PLAN}" | tac
```

Expected pattern:
```
abc1234 test(03-01): add failing tests for user validation
def5678 feat(03-01): implement user validation
ghi9012 refactor(03-01): extract validation helpers
```

**Red flags:**
- `feat` commit with no preceding `test` commit → TDD not followed
- Only `feat` commits → tests written after (or not at all)
- `test` commit after `feat` commit → backwards

Report compliance in phase summary.
</step>

<step name="aggregate_results">
After all waves, standard execute-phase aggregation PLUS TDD metrics:

```markdown
## Phase {X}: {Name} — TDD Execution Complete

**Waves:** {N} | **Plans:** {M}/{total} complete

### TDD Compliance

| Plan | Test Commits | Feat Commits | Refactor | TDD Order |
|------|-------------|-------------|----------|-----------|
| {XX-01} | {N} | {N} | {N} | ✓ Correct |
| {XX-02} | {N} | {N} | {N} | ✓ Correct |

**Tests written:** {total test count}
**All passing:** {yes/no}

{Standard execute-phase aggregation follows}
```
</step>

<step name="offer_next">
Standard execute-phase next steps, plus:

```
**Also available:**
- /tdd:review — verify test quality matches the plan
- cat {test_plan_path} — compare results to plan
```
</step>

</process>

<failure_handling>
All standard execute-phase failure handling applies.

Additional TDD-specific failures:

**Test won't fail in RED phase:**
- Feature may already exist (from prior plan or prior implementation)
- Test may be wrong (not testing what it claims)
- Executor should investigate and document in SUMMARY.md

**Test won't pass in GREEN phase:**
- Debug implementation, iterate
- If stuck >3 iterations: note as deviation, continue with next task

**Tests break in REFACTOR phase:**
- Undo refactor, keep GREEN state
- Document in SUMMARY.md
</failure_handling>
