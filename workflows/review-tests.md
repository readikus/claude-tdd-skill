<purpose>
Orchestrate review of existing test suites for anti-patterns, bad practices, and coverage gaps. Spawns tdd-reviewer agent, presents findings.
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

**No argument:** Review all tests in project
```bash
TARGET="."
```

Count test files:
```bash
TEST_COUNT=$(find ${TARGET} \( -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" -o -name "test_*" \) -not -path "*/node_modules/*" -not -path "*/.git/*" | wc -l | tr -d ' ')
```

If TEST_COUNT == 0:
```
No test files found in ${TARGET}.

Run /tdd:plan to create a test plan first.
```
Exit.
</step>

<step name="setup">
Create `.tdd/` if it doesn't exist:
```bash
mkdir -p .tdd
```

Check for existing TEST-PLAN.md (for plan compliance comparison):
```bash
TEST_PLAN=""
if [ -f .tdd/TEST-PLAN.md ]; then
  TEST_PLAN=$(cat .tdd/TEST-PLAN.md)
fi
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
</review_context>

<output>
Write review to: .tdd/TEST-REVIEW.md
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
- Proceed to present

**`## TEST REVIEW BLOCKED`:**
- Display reason
- Offer alternatives

</step>

<step name="present_findings">
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

1. {file:line — pattern name — brief description}
2. {file:line — pattern name — brief description}
3. {file:line — pattern name — brief description}

### Coverage Gaps

{N} source files have no tests:
- {file path} — {N} public functions untested

───────────────────────────────────────────────────────

Full report: cat .tdd/TEST-REVIEW.md

───────────────────────────────────────────────────────

## ▶ Recommended

{If critical findings:}
Fix critical issues first — these tests may be giving false confidence.

{If coverage gaps:}
/tdd:plan {path} — create test plan for uncovered code

───────────────────────────────────────────────────────
```
</step>

</process>

<success_criteria>
- [ ] Review scope correctly determined
- [ ] .tdd/ directory exists
- [ ] tdd-reviewer agent spawned with complete context
- [ ] Review report created at .tdd/TEST-REVIEW.md
- [ ] Key findings displayed to user
- [ ] Coverage gaps identified
- [ ] If TEST-PLAN.md exists: plan compliance checked
- [ ] Actionable next steps provided
</success_criteria>
