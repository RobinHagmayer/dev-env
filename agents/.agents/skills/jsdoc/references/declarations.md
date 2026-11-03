# Declarations and tags

## 1. Identify the project profile before choosing a format

Inspect local instructions, two or three nearby public APIs, package exports,
and configuration such as `tsdoc.json`, `typedoc.json`, `docgen.json`,
`jsdocs.config.json`, ESLint rules, and build/check scripts.

The defaults below fill gaps; they do not migrate an existing profile.
Follow the project's documentation language and terminology. Without an existing
convention, use practical English for API comments.

| Existing profile | Approach |
| --- | --- |
| TypeScript without a fixed documentation schema | Short description plus necessary semantics; additional tags only when useful and supported |
| JavaScript with JSDoc types / `checkJs` | Preserve and update type annotations; they may define the actual static API |
| JSDoc / TypeDoc / TSDoc with local rules | Preserve supported tags and syntax; do not replace `@example`, `@remarks`, `@returns`, or `@typeParam` with Effect headings |
| Explicitly configured Effect-style profile | Follow local requirements for headings, tag order, categories, versions, and stability |

Depending on `effect` does not make a project the Effect monorepo.
For a linter diagnostic, inspect the active local configuration rather than
guessing its rules by adding tags or weakening the linter.

## 2. Document at the right level

- **Module header:** Purpose, boundary, and relationships when they help readers
  navigate the module. Do not force an overview into every file. Check whether
  the consumer treats the header as module or declaration documentation.
- **Public declaration:** Attach documentation to the consumed export or public
  type contract. For aliases and overloads, check where existing tooling reads
  JSDoc. Do not blindly duplicate comments onto every signature.
- **Configuration field/member:** Explain units, defaults, allowed values,
  ownership, timing, or other non-obvious semantics directly at the field.
- **Re-export/barrel:** A thin export does not need the entire original guide
  repeated. Follow local metadata conventions; update generated sections only
  through their generator.
- **Private implementation:** Explain a non-obvious decision rather than applying
  a public API template. Loading this skill does not mean documenting every
  local function.

Preserve accurate prose during behavior-preserving refactoring. When a public
contract changes, update only the affected documentation; do not start a
whole-module documentation rewrite as a side task.

## 3. Content: what the signature does not say

Start with a short, self-contained paragraph. For functions, use a concrete verb
such as `Creates`, `Returns`, or `Converts`; for types, describe the modeled
concept.

Add only verified information relevant to callers:

- **When to use it:** The choice relative to a close alternative.
- **When work happens:** Immediately, lazily, on await, when an Effect runs,
  or during resource acquisition.
- **Errors:** Throws vs. rejections vs. typed failures vs. defects; do not infer
  guarantees from method names.
- **Data:** Mutation, copies, ordering, duplicates, `null`/`undefined`, empty
  inputs, and units.
- **Lifecycle:** Ownership, cleanup, reuse, concurrency, and cancellation.
  An `AbortSignal` parameter does not prove that underlying work stops.

Without another schema, optional `**When to use**`, `**Details**`, and
`**Gotchas**` sections work well in that order. Avoid empty or redundant
sections. These headings are a readable default, not universally required
TSDoc syntax.

## 4. Use metadata only with verified meaning

| Tag | Decision |
| --- | --- |
| `@param`, `@returns`, `@typeParam` | In TS, explain additional meaning without copying types; follow local parameter names and supported syntax. In JS, `@param {Type}` and `@returns {Type}` may be necessary. |
| `@throws` | Describe verified throwing behavior in a supporting profile; do not describe a Promise rejection as a synchronous throw. |
| `@default` / `@defaultValue` | Document the effective default exactly; the profile determines the tag and format. An `undefined` input is not necessarily the effective default. |
| `@since` | Use only when the project tracks versions this way. Preserve history, do not bump for prose edits, and do not infer the version from the current `package.json`. |
| `@category` | Reuse the existing taxonomy instead of creating a category for every change. |
| `@stability` | Use only with an established convention and verified guarantee. Do not assign `experimental` or `unstable` based solely on personal judgment. |
| `@deprecated` | Name a supported alternative and any necessary migration guidance; deprecation itself is an API decision, not an editorial guess. |
| `@internal` | Do not add as a decorative label: it can change reference documentation and emitted `.d.ts` files. Check tooling and export boundaries. |
| `@see`, `{@link ...}` | Verify the target and its public visibility; link genuine alternatives, inverses, or complements. Follow local URL conventions, otherwise use Markdown links. |

### Categories as guidance, not a required list

Commonly useful: `constructors`, `models`, `utility types`, `guards`,
`predicates`, `converting`, `mapping`, `error handling`, `services`, `layers`.

Distinguish a guard (narrows a type) from a predicate (returns a boolean), a
service contract from its provision, and an error model from error handling.
These names are suggestions; local vocabulary takes precedence.

## 5. Special case: the Effect monorepo

At the researched Effect revision, public root declarations require
`@stability`, `@category`, and `@since`; namespace and member rules differ.
There, `@example` tags are forbidden and examples use `**Example** (Title)`.
Common TypeDoc/TSDoc tags are not automatically allowed.

Even there, read current local guidance and checker configuration.
Do not export this specific rule set into unrelated projects.
