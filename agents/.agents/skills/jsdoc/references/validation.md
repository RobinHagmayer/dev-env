# Validating documentation changes

## Identify the project's verification path

Read package-manager/workspace configuration and existing scripts/CI steps.
Use the narrowest existing checks covering the changed files.
Do not install tools or dependencies solely to satisfy this skill.

| Change | Appropriate existing evidence |
| --- | --- |
| Prose, tags, links | Doc linter/extractor and formatting; additionally verify link targets and semantics yourself |
| Example code | Relevant example runner and, if available, a separate snippet typecheck |
| JS JSDoc types | Project typecheck with `checkJs`/appropriate configuration; this may change the type API |
| Overload/export/`@internal` placement | Relevant generated API/declaration output and existing build/API checks |
| Type behavior | Existing type tests; do not substitute an arbitrary runtime assertion |
| Runtime behavior within an authorized code change | Targeted behavior tests and typecheck in addition to documentation checks |

Without a runner, do not claim an example was tested. If useful, perform a
clearly identified temporary probe using existing tools, without adding
production exports, test-only interfaces, or dependencies.

Typechecking a source file does not normally check code **inside comments**.
A runner that only transpiles TypeScript does not prove type correctness.
A doc linter does not automatically verify a documented default.

## Only in the appropriately configured Effect repository

These commands are a verified project example, not a general requirement for
projects depending on `effect`:

```sh
pnpm jsdocs --check
pnpm lint
pnpm doctest --run packages/effect/src/Option.ts
```

First confirm scripts and current repository instructions. Choose a targeted
local run; do not accidentally start watch mode or a full build.
`jsdocs --check` may update its generated JSON output; `--check` does not
universally mean read-only.

## Final review

- Does each new guarantee match the implementation, tests, and call sites?
- Are error, default, mutation, cancellation, and lifecycle claims supported?
- Are references valid, public, and useful?
- Does each new example show a relevant result or a specifically checked type
  claim? Is its actual verification status clear?
- Have you avoided inventing versions/stability guarantees and editing generated
  files instead of their sources?
- Has documentation-only work remained free of unauthorized runtime changes?
- Are checks not run and unverified claims identified with reasons?

Report questions/blockers first, followed by a brief account of changes and
checks actually performed. Missing dependencies are not passing checks.
For review findings, give the file/line, violated user-facing contract, and
evidence or the verification step still needed.
