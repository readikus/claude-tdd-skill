<purpose>
Orchestrate test plan creation from GSD phases, Linear tasks, or standalone code analysis. Detects mode from arguments, loads context, spawns tdd-planner agent, handles ambiguity resolution.
</purpose>

<core_principle>
Requirements drive tests. Tests drive implementation. This workflow ensures requirements are analyzed for testability and ambiguity BEFORE any test code is written.
</core_principle>

<process>

<step name="detect_mode" priority="first">
Parse $ARGUMENTS to determine mode:

**GSD mode:** Argument is a phase number (integer or decimal like `2.1`)
- Validate: `.planning/` directory exists
- Load via: `gsd-tools.js init`

**Linear mode:** Argument starts with a Linear ID pattern (e.g., `ENG-123`, `PROJ-45`)
- Validate: Linear MCP tools available
- Can combine with GSD: `--phase 3` flag maps Linear task to a phase

**Standalone mode:** Argument is a file/directory path
- Validate: Path exists
- No GSD or Linear dependencies

**Auto-detect:** No argument
- If `.planning/` exists → GSD mode, detect next phase needing test plan
- Otherwise → Standalone mode, use current directory

```bash
# Check for GSD project
if [ -d ".planning" ]; then
  GSD_MODE=true
  INIT=$(node ~/.claude/get-shit-done/bin/gsd-tools.js init plan-phase "${PHASE_ARG}" --include state,roadmap,context,research 2>/dev/null)
fi
```
</step>

<step name="load_context">

### GSD Mode Context
```bash
# Load phase plans
PLANS=$(cat .planning/phases/${PHASE_DIR}/*-PLAN.md 2>/dev/null)

# Load phase context (user decisions)
CONTEXT=$(cat .planning/phases/${PHASE_DIR}/*-CONTEXT.md 2>/dev/null)

# Load existing test plan (if re-running)
EXISTING_TEST_PLAN=$(cat .planning/phases/${PHASE_DIR}/*-TEST-PLAN.md 2>/dev/null)

# Load codebase testing conventions
TESTING_CONVENTIONS=$(cat .planning/codebase/TESTING.md 2>/dev/null)
CONVENTIONS=$(cat .planning/codebase/CONVENTIONS.md 2>/dev/null)
```

### Linear Mode Context
```bash
# Fetch task via MCP (tool call, not bash)
# Use mcp__linear__get_issue or equivalent
# Extract: title, description, acceptance criteria, comments, labels
```

### Standalone Mode Context
```bash
# Detect project type and test framework
if [ -f package.json ]; then
  FRAMEWORK=$(cat package.json | grep -oE '"(jest|vitest|mocha|ava)"' | head -1 | tr -d '"')
  PROJECT_TYPE="node"
elif [ -f pyproject.toml ] || [ -f requirements.txt ]; then
  PROJECT_TYPE="python"
  FRAMEWORK="pytest"
elif [ -f go.mod ]; then
  PROJECT_TYPE="go"
  FRAMEWORK="go-test"
elif [ -f Cargo.toml ]; then
  PROJECT_TYPE="rust"
  FRAMEWORK="cargo-test"
fi

# Find existing tests to understand conventions
find ${TARGET_PATH} \( -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" -o -name "test_*" \) -not -path "*/node_modules/*" | head -5
```
</step>

<step name="check_existing_test_plan">
If TEST-PLAN.md already exists for this phase/path:

**Options:**
1. **Update** — Keep confirmed specs, re-analyze for new/changed requirements
2. **Replace** — Generate fresh test plan
3. **View** — Show existing plan and exit

If status is `draft` with unresolved ambiguities:
- Check if Linear comments have been answered
- If answered: update specs and set status to `confirmed`
- If not answered: remind user and exit
</step>

<step name="spawn_planner">
Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 TDD ► PLANNING TESTS {mode indicator}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ Analyzing requirements for testable behaviors...
```

Spawn tdd-planner agent:

```
Task(
  prompt="First, read the tdd-planner agent definition for your role and instructions.

<planning_context>
**Mode:** {gsd|linear|standalone}
**Target:** {phase number | linear task ID | file path}

**Test framework:** {detected framework or 'detect'}
**Project type:** {node|python|go|rust|unknown}

{MODE-SPECIFIC CONTEXT}

**For GSD mode:**
**Plans:** {plans_content}
**Phase context:** {context_content}
**Roadmap:** {roadmap_content}
**Testing conventions:** {testing_conventions}

**For Linear mode:**
**Task:** {linear_task_json}
**Codebase context:** {relevant source files}

**For Standalone mode:**
**Target path:** {path}
**Source files found:** {file list}
**Existing tests found:** {file list}
</planning_context>

<output>
Write TEST-PLAN.md to: {output_path}
</output>
",
  subagent_type="general-purpose",
  description="Plan TDD tests"
)
```
</step>

<step name="handle_planner_return">

**`## TEST PLAN COMPLETE`:**
- Display coverage summary
- If ambiguities posted to Linear: report which questions
- Proceed to offer_next

**`## TEST PLAN BLOCKED`:**
- Display reason
- Offer: provide context, change mode, abort

</step>

<step name="commit_test_plan">
If GSD mode and commit_docs enabled:
```bash
node ~/.claude/get-shit-done/bin/gsd-tools.js commit "docs(${PHASE}): create TDD test plan" --files .planning/phases/${PHASE_DIR}/*-TEST-PLAN.md
```

If standalone: no auto-commit.
</step>

<step name="offer_next">
Output:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 TDD ► TEST PLAN READY ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**{Title}** — {N} test specs across {M} features

| Feature | Unit | Integration | Edge Cases |
|---------|------|-------------|------------|
| {name} | {N} | {N} | {N} |

Status: {confirmed | draft (N ambiguities pending)}

───────────────────────────────────────────────────────

## ▶ Next Up

{If GSD mode:}
**Execute with TDD** — write tests first, then implement

/tdd:execute {phase}

{If standalone:}
**Review existing tests** for comparison

/tdd:review {path}

{If draft with ambiguities:}
**Waiting for clarification** on {N} questions
Check Linear task {ID} for responses, then re-run /tdd:plan {args}

<sub>/clear first → fresh context window</sub>

───────────────────────────────────────────────────────

**Also available:**
- cat {test_plan_path} — review full test plan
- /tdd:review {path} — audit existing tests
- /tdd:help — all TDD commands

───────────────────────────────────────────────────────
```
</step>

</process>

<success_criteria>
- [ ] Mode correctly detected from arguments
- [ ] Context loaded for the detected mode
- [ ] tdd-planner agent spawned with complete context
- [ ] TEST-PLAN.md created at correct location
- [ ] Ambiguities handled (posted to Linear or flagged)
- [ ] Test plan committed (GSD mode)
- [ ] User knows next steps
</success_criteria>
