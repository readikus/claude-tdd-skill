<purpose>
Orchestrate review of existing test suites for anti-patterns, bad practices, and coverage gaps. Spawns tdd-reviewer agent, collects results, presents findings.
</purpose>

<core_principle>
Good tests are an asset. Bad tests are worse than no tests — they provide false confidence and slow down development. This workflow identifies which tests need attention.
</core_principle>

<process>

<step name="determine_scope" priority="first">
Parse $ARGUMENTS for review target:

**Path specified:** Review tests in that path
```bash
TARGET="${ARGUMENTS}"
[ -d "$TARGET" ] || [ -f "$TARGET" ] || echo "Path not found: $TARGET"
```

**Phase number:** Review tests for a GSD phase
```bash
# Find test files created by the phase
PHASE_SUMMARIES=$(cat .planning/phases/${PHASE_DIR}/*-SUMMARY.md 2>/dev/null)
# Extract test files from key-files sections
```

**No argument:** Review all tests in project
```bash
TARGET="."
```

Count test files to set expectations:
```bash
TEST_COUNT=$(find ${TARGET} \( -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" -o -name "test_*" \) -not -path "*/node_modules/*" -not -path "*/.git/*" | wc -l)
```

If TEST_COUNT == 0:
```
No test files found in ${TARGET}.

Run /tdd:plan to create a test plan first.
```
Exit.
</step>

<step name="load_reference_context">
```bash
# Load anti-patterns reference
ANTI_PATTERNS_REF="references/anti-patterns.md"

# Load existing TEST-PLAN.md if available (to compare plan vs reality)
TEST_PLAN=$(cat .planning/phases/${PHASE_DIR}/*-TEST-PLAN.md 2>/dev/null)

# Load project test conventions
TESTING_CONVENTIONS=$(cat .planning/codebase/TESTING.md 2>/dev/null)
```
</step>

<step name="spawn_reviewer">
Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 TDD ► REVIEWING TESTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ Analyzing {TEST_COUNT} test files...
```

Spawn tdd-reviewer agent:

```
Task(
  prompt="First, read the tdd-reviewer agent definition for your role and instructions.

<review_context>
**Target path:** {TARGET}
**Test file count:** {TEST_COUNT}
**Project type:** {node|python|go|rust}
**Test framework:** {detected framework}

{If TEST-PLAN.md exists:}
**Test plan available:** Compare actual tests against planned specifications.
{test_plan_content}

{If testing conventions exist:}
**Project conventions:** {testing_conventions}
</review_context>

<anti_patterns_reference>
{anti_patterns_content}
</anti_patterns_reference>

<output>
{If GSD mode:}
Write review to: .planning/phases/${PHASE_DIR}/${PHASE}-TEST-REVIEW.md

{If standalone:}
Write review to: TEST-REVIEW.md in the target directory
</output>
",
  subagent_type="general-purpose",
  description="Review test suite"
)
```
</step>

<step name="handle_reviewer_return">

**`## TEST REVIEW COMPLETE`:**
- Parse summary (severity counts, overall health)
- Display key findings
- Proceed to offer_next

**`## TEST REVIEW BLOCKED`:**
- Display reason
- Offer alternatives

</step>

<step name="present_findings">
Display condensed summary:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 TDD ► REVIEW COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Scope:** {N} test files, {M} source files
**Health:** {healthy ✓ | needs attention ⚠ | unhealthy ✗}

| Severity | Count |
|----------|-------|
| Critical | {N} |
| High     | {N} |
| Medium   | {N} |
| Low      | {N} |

### Top Issues

1. {most impactful finding — file:line — pattern name}
2. {second finding}
3. {third finding}

### Coverage Gaps

{N} source files have no tests:
- {file path} — {N} public functions untested

───────────────────────────────────────────────────────

Full report: cat {review_path}

───────────────────────────────────────────────────────
```
</step>

<step name="offer_next">
```
## ▶ Recommended Actions

{If critical findings:}
Fix critical issues first — these tests may be giving false confidence.

{If coverage gaps:}
/tdd:plan {path} — create test plan for uncovered code

{If GSD mode and phase has unfixed issues:}
/gsd:plan-phase {X} --gaps — plan fixes for test issues

{Always:}
cat {review_path} — read full review with line-specific suggestions

───────────────────────────────────────────────────────
```
</step>

</process>

<test_plan_comparison>
When a TEST-PLAN.md exists, the reviewer additionally checks:

1. **Planned vs Actual:** Are all planned test specs implemented?
2. **Spec Fidelity:** Do actual tests match the Given-When-Then specs?
3. **Anti-Pattern Guards:** Were the specific guards from the plan followed?
4. **Missing Specs:** Are there tests that weren't in the plan? (May indicate scope creep or good initiative)

This appears as an additional section in the review:

```markdown
### Plan Compliance

| Planned Spec | Status |
|---|---|
| should validate email format | ✓ Implemented |
| should reject empty password | ✓ Implemented |
| should handle database timeout | ✗ Missing |

**Compliance:** {N}/{M} specs implemented ({percentage}%)
```
</test_plan_comparison>

<success_criteria>
- [ ] Review scope correctly determined
- [ ] tdd-reviewer agent spawned with complete context
- [ ] Review report created at correct location
- [ ] Key findings displayed to user
- [ ] Coverage gaps identified
- [ ] If TEST-PLAN.md exists: plan compliance checked
- [ ] Actionable next steps provided
</success_criteria>
