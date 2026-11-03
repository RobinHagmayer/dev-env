---
name: jsdoc
description: >-
  Use this skill when implementing, changing, refactoring, or reviewing public
  JavaScript/TypeScript APIs: exported functions, classes, services, types,
  interfaces, and configuration options. Keep JSDoc/TSDoc aligned with the API
  contract even when the user does not explicitly mention documentation or
  comments. Also use for stale API comments, IDE hover text, documentation
  examples, and JSDoc/TypeDoc/docgen diagnostics. Not for formatting-only changes,
  import cleanup, private implementation details, test-only changes, or
  README/marketing copy unrelated to code APIs.
---

# JSDoc for usable APIs

Document what callers need to know, not what they can read from the code.
Project rules and existing tooling take precedence over this skill's defaults.

## Workflow

1. **Understand the contract.** Read local agent/contributor instructions, the
   affected declaration and implementation, nearby JSDoc, and relevant tests and
   call sites. Identify the actual public or shared module boundary; not every
   `export` is a published API.
2. **Identify the profile.** Inspect existing tags, comment style, package exports,
   documentation configuration, and validation scripts. Before writing, read
   [Declarations and tags](references/declarations.md). Do not introduce
   Effect-specific required tags or new tools without a project requirement.
3. **Document the affected contract.** Keep comments current when adding or
   changing APIs. Explain meaning, use cases, and verified edge cases. Preserve
   useful facts and examples; avoid comment churn during behavior-preserving
   refactoring.
4. **Choose examples.** Read [Examples](references/examples.md) when adding,
   changing, or reviewing examples. Use public imports and observable results.
   Examples are optional, not mandatory filler.
5. **Validate.** Read [Validation](references/validation.md), run the relevant
   existing checks on the affected scope, and inspect the diff for unintended
   code or generated-output changes.

## Boundaries

- In TypeScript, do not duplicate signature types in JSDoc type annotations.
  In JavaScript, JSDoc annotations may themselves define the type contract.
- Do not invent `@since` versions, stability guarantees, defaults, or links.
  Verify error, cancellation, mutation, and resource-ownership claims.
- `@internal`, barrel metadata, and overload placement can change the shipped
  API. Edit generator sources rather than generated output.
- During documentation-only work, do not silently fix a discovered runtime or
  type bug. Report its location. Ask about an unresolved intended contract
  before documenting that claim; continue independently verified work.
- Do not add a documentation pipeline, dependency, or repository-wide rewrite
  without authorization.

## Done when

The affected API is accurately documented in the project's style, links and
examples match the contract, and relevant checks pass or are explicitly reported
as not run or blocked. A passing doc linter does not prove semantic accuracy;
execution does not prove type correctness.

Keep the final report short: questions/blockers first, then documentation changes
and checks actually performed.

Load [Sources and scope](references/sources.md) only for provenance questions,
Effect-specific rules, or maintenance of this skill.
