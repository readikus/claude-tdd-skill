# TEST-PLAN.md Template

```markdown
---
title: {Feature or task name}
source: {linear:ENG-123 | path:src/auth | description}
test_framework: {jest|vitest|pytest|go-test|cargo-test}
coverage_strategy: {behavior-first|contract-first|risk-first}
status: {draft|confirmed|executing|complete}
created: {ISO date}
---

# Test Plan: {Title}

## Requirements

**Source:** {Linear task ENG-123 | Code analysis of src/auth | User description}

### Summary

{Bullet list of requirements being tested}

- {Requirement 1}
- {Requirement 2}
- {Requirement 3}

### Ambiguities

{Requirements that are unclear. In Linear mode, posted as comments for PM clarification.}

- [ ] {Ambiguous requirement} — **Question:** {clarification needed}

{If none: "None — requirements are clear."}

## Testing Strategy

**Approach:** {Why this strategy for this feature}
**Framework:** {framework} — {why, or "matches project convention"}

| Level | Count | What they cover |
|-------|-------|----------------|
| Unit tests | {N} | {scope} |
| Integration tests | {N} | {scope} |
| Not testing | — | {what's excluded and why} |

## Test Specifications

### {Feature 1}: {Name}

**Source file:** `{path/to/source.ext}`
**Test file:** `{path/to/source.test.ext}`

#### Behaviors

1. **`should {behavior}`**
   - Given: {precondition}
   - When: {action}
   - Then: {expected outcome}

2. **`should {behavior}`**
   - Given: {precondition}
   - When: {action}
   - Then: {expected outcome}

#### Edge Cases

3. **`should handle {edge case}`** — {why this matters}
   - Given: {edge condition}
   - When: {action}
   - Then: {expected behavior}

4. **`should reject {invalid input}`**
   - Given: {invalid state}
   - When: {action}
   - Then: {error/rejection}

#### Not Testing

- {Excluded behavior} — {reason}

---

### {Feature 2}: {Name}

{Same structure}

---

## Implementation Tasks

Tasks are executed in order. Each task follows RED-GREEN-REFACTOR.

<task name="{Task 1 name}">
  <files>{source file}, {test file}</files>
  <tests>
    Specs: {list of spec names from above}
  </tests>
  <implement>
    {What to build to make the tests pass}
  </implement>
  <done>{All N specs passing}</done>
</task>

<task name="{Task 2 name}">
  <files>{source file}, {test file}</files>
  <tests>
    Specs: {list of spec names}
  </tests>
  <implement>
    {What to build}
  </implement>
  <done>{All N specs passing}</done>
</task>

## Anti-Pattern Guards

{Specific to THIS plan — which anti-patterns are most likely and how to avoid them}

- [ ] **No Inspector tests** — test {module}'s output, not its internal method calls
- [ ] **No Mockery** — only mock {specific boundary}, use real {specific collaborator}
- [ ] **No Happy Path Only** — every behavior has at least one error/edge case test
- [ ] **No Giant tests** — each test verifies one behavior
```
