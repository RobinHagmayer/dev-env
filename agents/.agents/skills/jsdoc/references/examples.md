# Examples that teach something

## When an example helps

Add one for behavior not evident from the signature, meaningful composition, or
useful inference/narrowing. Do not add an example merely to call the API once.
A short comment can be complete without an example.

Use public imports from the actually installed API version. Do not import
internal helpers just to shorten an example. Avoid heavy scaffolding, real
secrets, external network dependencies, uncontrolled timing, and random results.

Separate setup, operation, and observation. Keep bindings for reuse or meaningful
multi-step flows, not merely to make an assertion longer.

## General TypeScript example

An original example for a project without required metadata. The important
contract is ordering, equality, and non-mutation, not `string[]`.

````ts
/**
 * Returns distinct strings in first-occurrence order without changing the input.
 *
 * **Gotchas**
 *
 * Matching is case-sensitive; values are not trimmed or normalized.
 *
 * **Example** (Keeping the first occurrence)
 *
 * ```ts
 * uniqueInOrder(["b", "a", "b", "A"]) // ["b", "a", "A"]
 * ```
 */
export function uniqueInOrder(values: readonly string[]): string[] {
  return [...new Set(values)]
}
````

The plain fence and result comment here are **illustrative only**.
They do not automatically make the example a test.

## JavaScript: type annotations are part of the contract

An original example for a classic JSDoc profile that supports `@example`:

```js
/**
 * Splits at the first separator, preserving the remaining suffix.
 *
 * @param {string} input - Text to split.
 * @param {string} separator - Non-empty, case-sensitive separator.
 * @returns {[string, string] | undefined} The two parts, or undefined if absent.
 * @throws {RangeError} If separator is empty.
 * @example
 * splitOnce("a=b=c", "=") // ["a", "b=c"]
 */
export function splitOnce(input, separator) {
  if (separator === "") throw new RangeError("separator must not be empty")
  const index = input.indexOf(separator)
  return index < 0
    ? undefined
    : [input.slice(0, index), input.slice(index + separator.length)]
}
```

In TypeScript, these types belong in the signature; do not mechanically copy
JavaScript type tags there. Additional parameter meaning may still be explained
using locally supported `@param` prose.

## Effect: an example with executable observations

The following JSDoc is copied from `Option.map`. It illustrates an established
Effect profile, not the minimum format for every TypeScript project.

````ts
/**
 * Transforms the value inside a `Some` using the provided function, leaving
 * `None` unchanged.
 *
 * **When to use**
 *
 * Use to apply a pure transformation to an `Option`'s present value, especially
 * when chaining transformations in a pipeline.
 *
 * **Details**
 *
 * - `Some` → applies `f` and wraps the result in a new `Some`
 * - `None` → returns `None` unchanged
 *
 * **Example** (Mapping over an Option)
 *
 * ```ts import.meta.vitest
 * import { Option } from "effect"
 *
 * Option.map(Option.some(2), (n) => n * 2) // => Option.some(4)
 * Option.map(Option.none(), (n: number) => n * 2) // => Option.none()
 * ```
 *
 * @see {@link flatMap} when `f` returns an `Option`
 * @see {@link as} to replace the value with a constant
 *
 * @stability stable
 * @category mapping
 * @since 2.0.0
 */
````

Source: Effect `packages/effect/src/Option.ts:1094`,
commit `9a91b1926a5fbfaffd302a7a41a94d4d53a1154e`.
Both link targets resolve in the original module, not in a standalone comment
copied into an arbitrary project. The MIT license notice is bundled in
`references/effect-license.txt`.

## Verify executability explicitly

- `import.meta.vitest` and `// =>` become tests only with the corresponding
  doctest tooling configured. They are not automatically executable assertions
  in other projects.
- In Effect doctests, expected values are expressions in the same scope.
  Comparison uses `Equal.equals`, not printed console output.
- Await promises and run Effects explicitly. Asynchronous cleanup must complete
  before the snippet finishes.
- Prefer `await Effect.runPromise` in Effect examples; use `runSync` only when
  synchronous execution is genuinely part of the contract.
- Do not add tautological runtime assertions for type-only claims. Verify
  inference through the existing type-test or snippet-typecheck path.
- Do not blindly mark examples as doctests if they register tests themselves,
  start servers, run indefinitely, or are intentionally incomplete.
- For concurrency, use existing deterministic synchronization primitives rather
  than arbitrary sleeps or uncontrolled mutable probes.

Runtime, syntax, and type checks provide different evidence.
A marked snippet without a result assertion proves, at most, that its executed
path did not fail unexpectedly.
