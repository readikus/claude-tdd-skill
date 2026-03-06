<purpose>
Orchestrate test plan creation from Linear tasks, code analysis, or user descriptions. Detects mode from arguments, loads context, spawns tdd-planner agent, handles ambiguity resolution.
</purpose>

<core_principle>
Requirements drive tests. Tests drive implementation. This workflow ensures requirements are analyzed for testability and ambiguity BEFORE any test code is written.
</core_principle>

<process>

<step name="detect_mode" priority="first">
Parse $ARGUMENTS to determine mode:

**Linear mode:** Argument matches a Linear ID pattern (e.g., `ENG-123`, `PROJ-45`)
- Validate: Linear MCP tools available (check for mcp__linear__* tools)
- If Linear MCP not available: error with setup instructions

**Standalone mode:** Argument is a file/directory path, a description, or no argument
- Path: validate it exists
- Description: user describes what to build (free text)
- No argument: analyze current directory

```bash
# Detect project type and test framework
if [ -f package.json ]; then
  FRAMEWORK=$(node -e "try{const p=require('./package.json');const d={...p.dependencies,...p.devDependencies};console.log(d.vitest?'vitest':d.jest?'jest':d.mocha?'mocha':'')}catch{}" 2>/dev/null)
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
```
</step>

<step name="setup_tdd_directory">
Create `.tdd/` if it doesn't exist:

```bash
mkdir -p .tdd
```

Check for existing TEST-PLAN.md:
```bash
if [ -f .tdd/TEST-PLAN.md ]; then
  echo "Existing test plan found"
fi
```

If TEST-PLAN.md exists:
- If status is `draft` with unresolved ambiguities: check if Linear comments answered, offer to update
- Otherwise: offer to update, replace, or view existing plan
</step>

<step name="load_context">

### Linear Mode
Fetch task via Linear MCP tools. Extract title, description, acceptance criteria, comments, labels, subtasks.

Also scan the codebase for relevant files:
```bash
# Find source files that might be affected
find . \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.rs" \) -not -path "*/node_modules/*" -not -path "*/.git/*" | head -30

# Find existing tests
find . \( -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" -o -name "test_*" \) -not -path "*/node_modules/*" -not -path "*/.git/*" | head -20
```

### Standalone Mode (Path)
```bash
# Discover source and test files at the target
find ${TARGET_PATH} \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.rs" \) -not -name "*.test.*" -not -name "*.spec.*" -not -path "*/node_modules/*" | head -30

find ${TARGET_PATH} \( -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" -o -name "test_*" \) -not -path "*/node_modules/*" | head -20
```

### Standalone Mode (Description)
The user's description IS the requirements. No file discovery needed upfront — the planner derives what files to create.

</step>

<step name="spawn_planner">
Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 TDD ► PLANNING TESTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ Analyzing requirements for testable behaviors...
```

Spawn tdd-planner agent:

```
Task(
  prompt="First, read the tdd-planner agent definition for your role and instructions.

<planning_context>
**Mode:** {linear|standalone}
**Source:** {Linear task ID | path | user description}
**Test framework:** {detected framework or 'detect'}
**Project type:** {node|python|go|rust|unknown}

{FOR LINEAR MODE:}
**Linear Task:**
{task title, description, acceptance criteria, comments}

**Codebase files:** {relevant source file list}
**Existing tests:** {test file list}

{FOR STANDALONE PATH MODE:}
**Target path:** {path}
**Source files:** {file list}
**Existing tests:** {file list}

{FOR STANDALONE DESCRIPTION MODE:}
**Feature description:** {user's description}
**Project type:** {detected type}
</planning_context>

<anti_patterns_reference>
When generating anti-pattern guards, reference these patterns by name:
The Liar, The Giant, The Mockery, The Inspector, The Slow Poke,
The Freeloader, The Secret Catcher, Happy Path Only, The Nitpicker,
The Dead Tree, The Copy-Paste Plague, The Ice Cream Cone
</anti_patterns_reference>

<output>
Write TEST-PLAN.md to: .tdd/TEST-PLAN.md
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
- Offer: provide more context, try different mode, abort

</step>

<step name="offer_next">
Output:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 TDD ► TEST PLAN READY ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**{Title}** — {N} test specs, {K} implementation tasks

| Feature | Unit | Edge Cases | Integration |
|---------|------|------------|-------------|
| {name} | {N} | {N} | {N} |

Status: {confirmed | draft (N ambiguities pending)}

───────────────────────────────────────────────────────

## ▶ Next Up

{If confirmed:}
**Execute with TDD** — write tests first, then implement

/tdd:execute

{If draft with ambiguities:}
**Waiting for clarification** on {N} questions
Check Linear task {ID} for responses, then re-run:

/tdd:plan {ID}

───────────────────────────────────────────────────────

cat .tdd/TEST-PLAN.md — review full test plan

───────────────────────────────────────────────────────
```
</step>

</process>

<success_criteria>
- [ ] Mode correctly detected from arguments
- [ ] .tdd/ directory created
- [ ] Context loaded for the detected mode
- [ ] tdd-planner agent spawned with complete context
- [ ] TEST-PLAN.md created at .tdd/TEST-PLAN.md
- [ ] Ambiguities handled (posted to Linear or flagged)
- [ ] User knows next steps
</success_criteria>
