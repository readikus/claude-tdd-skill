<overview>
Reference catalog of TDD anti-patterns and bad practices. Used by the tdd-reviewer agent to audit existing test suites and by the tdd-planner agent to generate anti-pattern guards in TEST-PLAN.md.

Sources: Wikipedia TDD article, xUnit Patterns, Martin Fowler's testing guides, industry practice.
</overview>

<structural_anti_patterns>

## 1. The Liar
Tests that pass but don't actually verify anything meaningful. They give false confidence.

**Symptoms:**
- Assertions that are always true (`expect(true).toBe(true)`)
- Tests that never fail regardless of implementation
- Assertions on mocked return values rather than behavior

**Fix:** Each test must be able to fail when the behavior it describes is broken.

## 2. The Giant
Tests that verify too many things at once. When they fail, you can't tell what broke.

**Symptoms:**
- 10+ assertions in a single test
- Test name uses "and" ("should validate and save and notify")
- Setup longer than 20 lines

**Fix:** One concept per test. Split into focused tests with descriptive names.

## 3. The Mockery (Over-mocking)
Tests that mock so many dependencies they're testing the mocking framework, not the code.

**Symptoms:**
- More mock setup than actual assertions
- Mocking value objects or simple data structures
- Mocking the thing being tested
- Tests break when refactoring internals despite behavior being unchanged

**Fix:** Only mock at architectural boundaries (external services, databases, network). Use real objects for value types and simple collaborators.

## 4. The Inspector (Testing Implementation)
Tests that verify HOW something works rather than WHAT it does. Brittle under refactoring.

**Symptoms:**
- Asserting on private method calls
- Verifying internal state rather than output
- `expect(spy).toHaveBeenCalledWith(internalDetail)`
- Tests break when changing implementation without changing behavior

**Fix:** Test through the public API. Assert on outputs and observable side effects.

## 5. The Slow Poke
Tests that are unnecessarily slow, discouraging frequent runs.

**Symptoms:**
- Real network calls in unit tests
- Real database operations for logic tests
- Unnecessary sleep/setTimeout
- Loading entire application for a single function test

**Fix:** Fast unit tests with mocked I/O. Reserve real I/O for dedicated integration tests.

## 6. The Freeloader (Missing Assertions)
Tests that exercise code but never assert anything.

**Symptoms:**
- No expect/assert statements
- Only checking that code "doesn't throw"
- Relying on test framework's "no error = pass"

**Fix:** Every test must assert on expected behavior.

## 7. The Secret Catcher
Tests that pass because of hidden side effects or shared mutable state between tests.

**Symptoms:**
- Tests pass in suite but fail in isolation
- Tests fail when run in different order
- Global state modified in beforeEach without cleanup
- Tests depend on previous test's side effects

**Fix:** Each test must set up its own state. Use proper setup/teardown. No shared mutable state.

## 8. The Loudmouth
Tests that dump output to console, making it hard to spot real failures.

**Symptoms:**
- `console.log` scattered through tests
- Noisy output hiding actual test results
- Difficulty distinguishing test output from error output

**Fix:** Remove debug logging. Use test framework's built-in reporting.

## 9. The Greedy Catcher (Overly Broad Error Handling)
Tests that catch exceptions too broadly, masking real failures.

**Symptoms:**
- `expect(() => fn()).toThrow()` without checking error type/message
- `try/catch` blocks that swallow all errors
- Testing that "something throws" without specifying what

**Fix:** Assert on specific error types and messages.

## 10. The Sequencer (Order Dependency)
Tests that must run in a specific order to pass.

**Symptoms:**
- Test B uses data created by Test A
- Removing or reordering tests causes failures
- `describe` blocks that are actually sequential workflows

**Fix:** Each test is independent. Shared fixtures use proper setup/teardown.

</structural_anti_patterns>

<design_anti_patterns>

## 11. The Ice Cream Cone
Testing pyramid inverted — many E2E/integration tests, few unit tests.

**Symptoms:**
- Most tests require browser/server setup
- Test suite takes minutes to run
- Failures are hard to diagnose (which layer broke?)
- Small changes break many tests

**Fix:** Follow the testing pyramid: many unit tests (fast, isolated), fewer integration tests, minimal E2E tests.

## 12. The Dead Tree (Commented-Out Tests)
Tests that are commented out or skipped indefinitely.

**Symptoms:**
- `it.skip()`, `@pytest.mark.skip`, `// TODO: fix this test`
- Tests commented out "temporarily" months ago
- Skip without explanation

**Fix:** Delete dead tests. If the behavior matters, fix the test. If it doesn't, remove it.

## 13. The Copy-Paste Plague
Duplicated test code instead of shared fixtures or helpers.

**Symptoms:**
- Same setup code in 10+ tests
- Identical assertion patterns repeated
- Bug in setup requires fixing N tests

**Fix:** Extract shared setup into beforeEach/fixtures. Create assertion helpers for domain-specific checks. But don't over-abstract — readability matters.

## 14. The Nitpicker (Over-Specification)
Tests that assert on irrelevant details, breaking on any change.

**Symptoms:**
- Snapshot tests on entire page output
- Asserting exact error message strings (fragile)
- Testing exact CSS classes or HTML structure
- Asserting on timestamps or random values

**Fix:** Assert on the minimum needed to verify behavior. Use matchers (contains, matches pattern) over exact equality where appropriate.

## 15. The Happy Path Only
Tests that only cover success cases, missing error handling and edge cases.

**Symptoms:**
- All test names start with "should successfully..."
- No tests for invalid input, empty data, null values
- No tests for error/exception paths
- No boundary value testing

**Fix:** For every success test, consider: What if input is null? Empty? Too large? Wrong type? What if the dependency fails?

## 16. The Local Hero
Tests that only pass on the author's machine.

**Symptoms:**
- Hardcoded file paths (`/Users/john/...`)
- Depends on specific timezone, locale, or OS
- Requires local services not in CI
- Uses absolute paths instead of relative

**Fix:** Use relative paths, mock time/locale, containerize dependencies.

</design_anti_patterns>

<tdd_process_anti_patterns>

## 17. Writing Tests After Implementation
The most common TDD violation — writing implementation first, then tests.

**Symptoms:**
- Tests mirror implementation structure rather than behavior
- Tests only cover the happy path (because that's what was built)
- Tests feel like an afterthought
- No failing test commit before implementation commit

**Fix:** Strict RED-GREEN-REFACTOR: failing test first, then minimal implementation.

## 18. Skipping the Refactor Step
Going RED → GREEN and moving on without cleaning up.

**Symptoms:**
- Duplication accumulates in implementation
- "Minimal code to pass" becomes the final code
- Tech debt grows despite having tests

**Fix:** After GREEN, always pause and ask: "Is there obvious duplication or complexity I can remove while tests still pass?"

## 19. Writing Too Many Tests Before Implementation
Writing an entire test suite before any implementation (test-first waterfall).

**Symptoms:**
- 20 failing tests before writing any production code
- Tests constrain implementation too heavily upfront
- Can't iterate on design because tests are locked in

**Fix:** One test at a time. RED → GREEN → REFACTOR → next RED.

## 20. Testing Frameworks, Not Code
Writing tests that effectively test the framework/library rather than your logic.

**Symptoms:**
- Testing that React renders a component (that's React's job)
- Testing that Express routes return 200 (that's Express's job)
- Testing ORM query syntax

**Fix:** Test YOUR logic. Trust frameworks to do their job. Test the behavior you added on top.

</tdd_process_anti_patterns>

<severity_levels>

## Severity Classification

| Severity | Meaning | Action |
|----------|---------|--------|
| critical | Tests provide false confidence or miss real bugs | Fix immediately |
| high | Tests are brittle and slow down development | Fix soon |
| medium | Tests work but have maintainability issues | Fix when touching the code |
| low | Style/convention issues | Fix opportunistically |

**Mapping:**

| Anti-Pattern | Default Severity |
|---|---|
| The Liar | critical |
| The Freeloader | critical |
| Happy Path Only | critical |
| The Inspector | high |
| The Mockery | high |
| The Secret Catcher | high |
| The Giant | high |
| The Ice Cream Cone | high |
| The Slow Poke | medium |
| The Sequencer | medium |
| The Greedy Catcher | medium |
| The Nitpicker | medium |
| The Copy-Paste Plague | medium |
| The Dead Tree | low |
| The Loudmouth | low |
| The Local Hero | low |

</severity_levels>

<review_checklist>

## Quick Review Checklist

For each test file, check:

- [ ] Every test has at least one meaningful assertion
- [ ] Test names describe behavior, not implementation ("should reject empty email" not "test1")
- [ ] Tests are independent — can run in any order, can run in isolation
- [ ] Mocks are only at architectural boundaries, not on internals
- [ ] Both success and failure paths are tested
- [ ] No shared mutable state between tests
- [ ] No hardcoded paths, timestamps, or environment-specific values
- [ ] No commented-out or permanently skipped tests
- [ ] Setup code is proportional to what's being tested
- [ ] Tests survive implementation refactoring (test behavior, not structure)

</review_checklist>
