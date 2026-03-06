# TEST-PLAN.md Template

```markdown
---
phase: {XX-name}                          # GSD phase (omit for standalone)
source_plans: [{XX-01-PLAN.md}, ...]      # Plans analyzed (omit for standalone)
source_task: {LINEAR-ID}                  # Linear task ID (omit if not from Linear)
test_framework: {jest|vitest|pytest|go-test|cargo-test}
coverage_strategy: {behavior-first}       # behavior-first | contract-first | risk-first
status: {draft|confirmed|executing|complete}
---

# Test Plan: {Title}

## Requirements Source

{One of:}
- **GSD Phase {X}:** {Phase name} — derived from {N} plan(s)
- **Linear Task:** {ID} — {title}
- **Codebase Analysis:** {path analyzed}

### Requirements Summary

{Bullet list of requirements being tested. In GSD mode, derived from plan objectives and must_haves. In Linear mode, derived from task description. In standalone mode, derived from code analysis.}

### Ambiguities

{Requirements that are unclear or have multiple valid interpretations. In Linear mode, these get posted as clarification comments.}

- [ ] {Ambiguous requirement} — **Question:** {clarification needed}
- [ ] {Ambiguous requirement} — **Question:** {clarification needed}

{If no ambiguities: "None identified — requirements are clear."}

## Testing Strategy

**Approach:** {Why this strategy for this feature}

**Testing pyramid for this feature:**
- Unit tests: {N} — {what they cover}
- Integration tests: {N} — {what they cover}
- Not testing: {what's excluded and why}

**Framework:** {framework} — {why this choice, or "matches project convention"}

## Test Specifications

### {Feature/Module 1}: {Name}

**Source file:** `{path/to/source.ext}`
**Test file:** `{path/to/source.test.ext}`

#### Behaviors

1. **`should {behavior description}`**
   - Given: {precondition/setup}
   - When: {action/trigger}
   - Then: {expected outcome}

2. **`should {behavior description}`**
   - Given: {precondition/setup}
   - When: {action/trigger}
   - Then: {expected outcome}

#### Edge Cases

3. **`should handle {edge case}`** — {why this matters}
   - Given: {edge condition}
   - When: {action}
   - Then: {expected behavior}

4. **`should reject {invalid input}`** — {what could go wrong}
   - Given: {invalid state/input}
   - When: {action}
   - Then: {error/rejection behavior}

#### Not Testing

- {Excluded behavior} — {reason: e.g., "framework responsibility", "visual only", "covered by integration test"}

---

### {Feature/Module 2}: {Name}

{Same structure as above}

---

## Implementation Order

{Ordered list — earlier tests have no dependencies on later ones}

1. **{Test group 1}** — {rationale: e.g., "foundation — no dependencies"}
   - Tests: {list of test names}
   - Files: `{test file path}`

2. **{Test group 2}** — {rationale: e.g., "depends on group 1 types"}
   - Tests: {list of test names}
   - Files: `{test file path}`

3. **{Integration tests}** — {rationale: "requires unit-tested modules"}
   - Tests: {list of test names}
   - Files: `{test file path}`

## Anti-Pattern Guards

{Specific to THIS test plan — which anti-patterns are most likely and how to avoid them}

- [ ] **No Inspector tests** — test {module}'s output, not its internal method calls
- [ ] **No Mockery** — only mock {specific boundary}, use real {specific collaborator}
- [ ] **No Happy Path Only** — every behavior has at least one error/edge case test
- [ ] **No Giant tests** — each test verifies one behavior
- [ ] {Additional context-specific guard}

## GSD Integration

{Only present in GSD mode}

### Mapping to Plans

| Plan | Feature | Test Count | Priority |
|------|---------|-----------|----------|
| {XX-01} | {feature} | {N} | {high/medium/low} |
| {XX-02} | {feature} | {N} | {high/medium/low} |

### Execution Notes

- Tests from Plan {XX-01} should be written/passing before Plan {XX-02} implementation begins
- {Any cross-plan test dependencies}
```
