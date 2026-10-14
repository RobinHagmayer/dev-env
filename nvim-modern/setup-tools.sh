#!/usr/bin/env bash
# Only editor-owned tools; never modify a project's package.json or global npm.
set -euo pipefail
tools="${XDG_DATA_HOME:-$HOME/.local/share}/nvim-modern/tools"
if ! command -v npm >/dev/null && [[ ! -x "$tools/node_modules/.bin/npm" ]]; then
  command -v pnpm >/dev/null || { echo 'Install Node.js and pnpm first (ansible/playbooks/dev-tools.yml).' >&2; exit 1; }
  mkdir -p -- "$tools"
  # pnpm 12 treats "add npm" as a package-manager switch; use an alias.
  pnpm add --dir "$tools" --ignore-scripts editor-npm@npm:npm@latest
  [[ -x "$tools/node_modules/.bin/npm" ]] || { echo "Private npm installation failed" >&2; exit 1; }
fi
if ! command -v tree-sitter >/dev/null; then
  command -v cargo >/dev/null || { echo 'Install Rust first, then cargo install tree-sitter-cli --locked.' >&2; exit 1; }
  cargo install tree-sitter-cli --locked
fi
printf 'Editor prerequisites ready. Launch nvim-modern; :EditorHealth checks versions and other requirements.\n'
