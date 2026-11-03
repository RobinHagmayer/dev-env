# Sources and scope

## Skill format and automatic activation

Read on 2026-10-29:

- [Agent Skills Specification](https://agentskills.io/specification):
  YAML frontmatter, name, description, and relative file references.
- [Best practices](https://agentskills.io/skill-creation/best-practices):
  a small coherent task, concrete procedures, and progressive disclosure.
- [Optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions):
  imperative triggers, implicit use cases, and negative boundary cases.
- [Evaluating skill output quality](https://agentskills.io/skill-creation/evaluating-skills):
  distinguish trigger evaluation from output evaluation.

The description deliberately includes API work without an explicit documentation
request. It does not guarantee activation by every client or model.
Availability depends on the client's skill discovery.
No client-specific `user-invocable` or `disable-model-invocation` fields
are required.

## Basis in Effect

Researched: [Effect-TS/effect, commit 9a91b1926](https://github.com/Effect-TS/effect/tree/9a91b1926a5fbfaffd302a7a41a94d4d53a1154e),
core package 4.1.0.

Particularly relevant sources, all pinned to that revision:

- [JSDoc workflow](https://github.com/Effect-TS/effect/blob/9a91b1926a5fbfaffd302a7a41a94d4d53a1154e/.agents/skills/jsdocs/SKILL.md)
- [Declarations and tags](https://github.com/Effect-TS/effect/blob/9a91b1926a5fbfaffd302a7a41a94d4d53a1154e/.agents/skills/jsdocs/declarations.md)
- [Examples](https://github.com/Effect-TS/effect/blob/9a91b1926a5fbfaffd302a7a41a94d4d53a1154e/.agents/skills/jsdocs/examples.md)
- [Option.map](https://github.com/Effect-TS/effect/blob/9a91b1926a5fbfaffd302a7a41a94d4d53a1154e/packages/effect/src/Option.ts#L1094)
- [Effect.promise](https://github.com/Effect-TS/effect/blob/9a91b1926a5fbfaffd302a7a41a94d4d53a1154e/packages/effect/src/Effect.ts#L876)
- [JSDoc extractor](https://github.com/Effect-TS/effect/blob/9a91b1926a5fbfaffd302a7a41a94d4d53a1154e/packages/tools/jsdocs/src/Jsdocs.ts)
- [Doctest](https://github.com/Effect-TS/effect/blob/9a91b1926a5fbfaffd302a7a41a94d4d53a1154e/packages/tools/doctest/README.md)

Adopted: user-facing semantics rather than implementation narration, focused
decision guidance and gotchas, meaningful verifiable examples, proximity to the
public type contract, and distinct kinds of verification.

**Not adopted universally:** mandatory `@category`/`@since`/`@stability`,
the ban on `@example`, exact namespace rules, pnpm commands, doctest markers,
or a fixed documentation pipeline. Local project rules govern these choices.

The copied Option example is covered by Effect's MIT license, whose notice is
included in `references/effect-license.txt`. The general examples were written
for this skill.

## Evaluating changes to this skill

Load only when maintaining this skill, not for ordinary documentation work:

- `evals/trigger-queries.json`: positive implicit use cases and near-miss negatives.
- `evals/evals.json`: three self-contained output-evaluation tasks.

For actual trigger evaluations, run each query in a fresh client context with
the skill installed and inspect the tool trace to see whether `SKILL.md` was
loaded. Use multiple runs; do not infer trigger rates from keyword searches.
Run output evaluations with and without the skill in separate temporary
workspaces. Write fixture code from the prompt there, not into a user project.
Label results and unverified cases honestly.

These files define expectations. Their existence is not a passing agent
benchmark or evidence of improvement over a baseline.
