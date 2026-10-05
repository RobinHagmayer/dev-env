#!/usr/bin/env bash
# Networked, fully isolated tests. Requires existing Node/pnpm and parser CLI.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
for tool in pnpm node tree-sitter cc git curl; do
  command -v "$tool" >/dev/null || { echo "Missing test prerequisite: $tool" >&2; exit 1; }
done
sandbox=$(mktemp -d)
trap 'rm -rf -- "$sandbox"' EXIT
export XDG_CONFIG_HOME="$sandbox/config" XDG_DATA_HOME="$sandbox/data"
export XDG_STATE_HOME="$sandbox/state" XDG_CACHE_HOME="$sandbox/cache"
export NVIM_APPNAME=nvim-modern
mkdir -p "$XDG_CONFIG_HOME" "$sandbox/projects/deps"
cp -a "$root/.config/nvim-modern" "$XDG_CONFIG_HOME/nvim-modern"
bash "$root/setup-tools.sh"
export PATH="$XDG_DATA_HOME/nvim-modern/tools/node_modules/.bin:$PATH"
export MODERN_FIXTURE="$sandbox/lua"
export MODERN_EFFECT_FIXTURES="$sandbox/projects"
export MODERN_LEGACY_FIXTURE="$sandbox/projects/classic"
node --input-type=module <<'JS'
import fs from "node:fs";
import path from "node:path";
const put = (filename, content) => {
  fs.mkdirSync(path.dirname(filename), { recursive: true });
  fs.writeFileSync(filename, typeof content === "string" ? content : JSON.stringify(content, null, 2));
};
const base = process.env.MODERN_EFFECT_FIXTURES;
put(base + "/deps/package.json", { private: true });
put(process.env.MODERN_FIXTURE + "/.luarc.json", {});
put(process.env.MODERN_FIXTURE + "/sample.lua", "local x={a=1,b=2}\n-- needle\nlocal function add(a, b)\nreturn a+b\nend\n");
for (const name of ["effect-lsp", "effect-oxlint"]) {
  put(base + "/" + name + "/package.json", { private: true, type: "module" });
  put(base + "/" + name + "/sample.ts", 'import { Effect } from "effect"\nEffect.log("Hello world!")\n');
  put(base + "/" + name + "/tsconfig.json", {
    compilerOptions: { target: "ESNext", module: "NodeNext", strict: true, skipLibCheck: true,
      plugins: [{ name: "@effect/language-service", diagnostics: name === "effect-lsp" }] },
    include: ["sample.ts"]
  });
}
put(base + "/effect-oxlint/.oxlintrc.json", {
  "$schema": "./node_modules/@effect/tsgo/oxlint-schema.json",
  extends: ["./node_modules/@effect/tsgo/oxlint-presets/recommended.json"]
});
put(base + "/classic/package.json", { private: true, type: "module" });
put(base + "/classic/tsconfig.json", { compilerOptions: { strict: true }, include: ["sample.ts"] });
put(base + "/classic/sample.ts", 'const count: number = "bad"\nexport { count }\n');
JS
pnpm add --dir "$sandbox/projects/deps" --ignore-scripts -D \
  @effect/tsgo@0.48.1 typescript@7.0.2 effect@4.0.0 oxlint@1.86.0 oxlint-tsgolint@7.0.2003
(cd "$sandbox/projects/deps" && ./node_modules/.bin/effect-tsgo patch --oxlint)
ln -s ../deps/node_modules "$sandbox/projects/effect-lsp/node_modules"
ln -s ../deps/node_modules "$sandbox/projects/effect-oxlint/node_modules"
pnpm add --dir "$sandbox/projects/classic" --ignore-scripts -D typescript@5.9.3
export MODERN_HEADLESS="$root/tests/headless.lua"
for script in integration.lua palette.lua effect.lua legacy-typescript.lua; do
  export MODERN_TEST_SCRIPT="$root/tests/$script"
  timeout 240 "${NVIM_MODERN_BIN:-nvim}" --headless '+lua dofile(vim.env.MODERN_HEADLESS)'
done
