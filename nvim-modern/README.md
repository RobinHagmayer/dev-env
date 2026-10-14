# Modern Neovim, without replacing the old editor

**Goal:** a usable editor that follows the project, explains its features, and
does not require learning its plugin configuration.

## Launch and rollback

From the repository root:

```sh
bash nvim-modern/setup-tools.sh
stow --simulate --verbose nvim-modern
stow nvim-modern
nvim-modern
# Or, using whichever nvim binary is on PATH:
NVIM_APPNAME=nvim-modern nvim
```

The launcher prefers `~/.local/opt/nvim-modern/bin/nvim`, falling back to `nvim`.
`NVIM_MODERN_BIN=/path/to/nvim nvim-modern` overrides it.

**Normal `nvim` still loads your original configuration.** We neither source nor
modify `nvim/.config/nvim`. Neovim's `NVIM_APPNAME` isolates config, plugin
installations, undo/history/state, cache, and Mason tools. To disable the new
app: `stow -D nvim-modern`. Its local data remains; nothing is deleted.

The same isolation does **not** sandbox projects or external language servers.
Project-local binaries run with your normal user's privileges, as in other
editors. Project configuration is read, never automatically patched, and
project-local Lua execution (`exrc`) is disabled.

## Runtime and prerequisites

The current upstream Neovim HEAD is pinned in
`ansible/playbooks/neovim-modern.yml` and built into its own user prefix:

```sh
cd ansible
uv sync
uv run ansible-playbook playbooks/neovim-modern.yml --ask-become-pass
# Prerequisite apt packages already installed:
uv run ansible-playbook playbooks/neovim-modern.yml --skip-tags packages
```

This does not replace the system binary or runtime. HEAD is experimental; the
existing editor is your fallback. The config requires Neovim **0.12+**.
The ordinary `neovim.yml` still provides the latest stable **0.12.5** system DEB.

Need Git, curl, tar, a C compiler, Node.js, npm, and Tree-sitter CLI **0.26.1+**.
Ripgrep is useful for auxiliary pickers. Install developer runtimes with the
existing dev-tools playbook if absent. `setup-tools.sh` supplies missing npm in
this app's data directory via pnpm (no global npm changes) and missing
Tree-sitter CLI via Cargo (not npm). It downloads packages explicitly; it does
not run during editor startup. An already-present outdated CLI is reported by
`:EditorHealth`; update it with `cargo install tree-sitter-cli --locked`.
The private npm dependency can be updated by rerunning its
`pnpm add --dir ~/.local/share/nvim-modern/tools --ignore-scripts editor-npm@npm:npm@latest`.

Plugins install on first launch, using **native `vim.pack`**. Initial installation
requires the network. FFF downloads a native binary with a Cargo build fallback.
Parser and server installs happen asynchronously as you open supported files;
the first file may briefly lack those features. Failures are visible in
`:Mason`, `:messages`, or health checks, and ordinary editing remains available.

## The few things worth remembering

Leader is **Space**.

| Keys | Purpose |
| --- | --- |
| Space ? | Search actions available in this buffer; select one to run |
| Space h a | All features, including why an action is unavailable |
| Space h h | Read-only feature guide; q closes |
| Space h k | Keybinding hints; pausing after a prefix also shows them |
| Space h c | Search commands, including plugin commands |
| Space f f / f g | Find project files / search their contents |
| Space f w | Search the cursor word or visual selection |
| Space f m / f t | Modified files / exactly Git-tracked files |
| Space f b | Switch open buffers |
| K / gd / grr / grn | Hover / definition / references / rename |
| gra | Actual fixes and refactors at the cursor or visual selection |
| Space c s | Whole-file source actions, such as organize imports |
| Space c t | Explain the selected TypeScript/Effect tooling |
| Space c d / c q | Full diagnostic message / diagnostic quickfix list |
| Space c f | Format buffer or visual selection, explicitly |
| Space c i | Toggle inlay hints, if supported |
| Space t f / t e | Select function / expand syntax selection |
| ]m / [m | Next / previous function |
| Space t n / t p | Swap with next / previous argument |
| Space u h | Health checks |
| Space u p / u t / u s | Update plugins / all installed Mason tools / parsers |

Completions appear automatically. **C-n/C-p** select, **C-y** accepts, **C-e**
cancels, **C-space** opens suggestions/documentation. **Enter remains a newline**;
Tab/Shift-Tab navigate snippet fields. No automatic suggestion insertion.

Tree-sitter text objects: `af/if` around/inside a function, `aa/ia`
around/inside an argument. Combine with `v`, `d`, `c`, or `y`.
For example: `vaf` selects a function; `cif` changes its body.
Neovim also provides visual `an/in` for growing/shrinking a syntax selection.
Syntax folds start open: `za` toggles, `zM` closes, `zR` opens.

Native `gcc/gc` comments code. MiniSurround supplies `sa/sd/sr` to add/delete/
replace quotes and brackets. These also appear in the guide.

## Reminders, not interruptions

After a minute of editing, idle normal mode may put **one tip in the status
line**. No popup, no message spam, no LSP requests on cursor movement.
A new tip is considered at most every ten minutes. An individual feature is
not suggested again for a week; actions invoked through our mappings/palette
are suppressed for two weeks. This is modest local bookkeeping, not telemetry.

- Space h d dismisses the current feature's reminder permanently.
- Space h s snoozes reminders for a day.
- `:EditorReminders off|on|snooze|dismiss|reset` controls them.
- State stores action IDs and timestamps under `stdpath("state")`, not project
  paths, file contents, or keystrokes.

Built-in or plugin mappings not routed through our action list are not tracked.
Text-object selection through our mappings is tracked; a purely native motion
is not. This is intentional rather than trying to monitor every keystroke.

## FFF defaults and help

The current upstream repository is `dmtrKovalenko/fff` (renamed from `fff.nvim`).
Search scope follows the buffer's Git root, then its package root/current
directory. Whole-home and filesystem-root indexing is disabled.

Grep starts **literal**, with **Shift-Tab** switching to regex. Fuzzy grep is
not in the default cycle. The UI starts in insert mode, with a top prompt and no
debug scores. Files open in the window you invoked the picker from.

Inside FFF, **F1** explains split opening, preview scrolling, query history,
marking results and sending them to quickfix. Query filters include
`git:modified`, `git:staged`, `src/`, `*.ts`, and `!test/`.

Exact Git-tracked file selection uses `git ls-files -z` and a small MiniPick
picker. It is not falsely described as equivalent to excluding ignored files.
FFF remains the primary file/content search tool.

## LSP and TypeScript / Effect

Server definitions come from current nvim-lspconfig, activated using
`vim.lsp.config` / `vim.lsp.enable`, not the deprecated setup API.
Mason installs servers **on demand by filetype** (TypeScript, Lua, Rust,
Go, Python, shell, JSON, YAML, HTML, CSS, C/C++). Extend the straightforward
`servers` table in `lua/editor/lsp.lua` for another language.

LSP actions are offered based on attached clients' actual capabilities.
Choosing code actions asks those servers for their real available actions;
we don't pretend capability flags tell us which refactor exists at the cursor.
Whole-file source actions are exposed separately, because some servers omit
them from ordinary cursor actions.

For JavaScript/TypeScript, the editor selects **one** type server:

1. Closest project-local `tsc` or `tsgo` that reports TypeScript **7+**:
   native LSP with `--lsp --stdio`. A patched compiler from Effect's project
   setup is used here, not a globally installed unpatched compiler.
2. Otherwise `typescript-language-server` from Mason, using the closest
   local legacy `tsserver.js` when present (managed fallback when absent).

Ancestor lookup stops at the Git boundary, supports package-local or workspace
dependencies, and checks all local native candidates before a managed fallback.
TypeScript tool selection is deliberately not a generalized project framework.
Restart the editor after installing/patching/changing project compiler versions.

### Effect v4

Follow [Effect's current devtools guide](https://effect.website/docs/v4/getting-started/devtools)
and [the tsgo setup README](https://github.com/Effect-TS/tsgo).
Use the project's package manager and request `@effect/tsgo setup --help` for
guided/noninteractive setup. The project needs:

- `@effect/tsgo` and a compatible native TypeScript installation;
- the `@effect/language-service` plugin in `tsconfig.json`;
- the patch applied, normally via the project's `prepare` script.

The editor does **not** infer a working patch merely from package presence.
Space c t explains what it selected. No dependency, patch, script, diagnostic
severity, or lint configuration is silently added to the project.

### Oxlint

Projects with a local Oxlint binary and `.oxlintrc.json`,
`.oxlintrc.jsonc`, or `oxlint.config.ts` also get the Oxlint LSP.
A local `tsgolint` companion enables its type-aware mode. Rules and presets stay
project-owned; no editor ESLint/Oxlint ruleset is injected.

For Effect's type-aware Oxlint integration, apply `effect-tsgo patch --oxlint`
and use the recommended Effect preset/schema from the devtools guide.
Set the TypeScript plugin's **`diagnostics: false`** when Oxlint owns Effect
diagnostics. Keep the LSP for hover, refactors, completion, and standard
TypeScript diagnostics. The editor intentionally does not rewrite that setting.

Vite Plus's bundled Oxlint, Deno-specific switching, debugger integrations, and
mermaid graph rendering are not included in this first version.

## Structure and updates

`init.lua` loads ordinary modules in `lua/editor/`: options, plugins, guide,
navigation, completion, treesitter, lsp/typescript, formatting, editing, health.
The guide has a small list of action records so the mapping, description,
availability and reminder refer to the **same feature**. No custom plugin
manager, dependency injection, auto-discovery framework or project-executed Lua.

Formatting is explicit. Conform prefers project-local Oxfmt/Prettier, with
Mason's Prettier fallback; StyLua, Ruff and shfmt are supplied by Mason.
LSP formatting is a final fallback. No format-on-save surprises.

The plugin lockfile is **generated by Neovim**, tracked with the config,
and records the tested revisions. Plugins follow current upstream branches,
except Blink: the latest released **v1** line is used because v2's own README
explicitly warns of breaking changes during development.

Space u p opens Neovim's native update review: `:write` accepts, `:quit`
cancels. Tree-sitter parsers update when its plugin updates; FFF's native binary
is rebuilt/downloaded when it updates. Restart afterwards.
Space u t explicitly updates **all installed Mason packages**, not project
dependencies. Update the runtime SHA in the modern playbook deliberately.

On another machine with existing plugins, pulling the lockfile alone does not
switch installed revisions: use
`:lua vim.pack.update(nil, { target = "lockfile" })` and review the changes.

## Tests and documentation consulted

```sh
bash nvim-modern/tests/run.sh
# Use the isolated latest runtime:
NVIM_MODERN_BIN="$HOME/.local/opt/nvim-modern/bin/nvim" bash nvim-modern/tests/run.sh
# Networked integration tests: isolated temporary projects and app directories.
NVIM_MODERN_BIN="$HOME/.local/opt/nvim-modern/bin/nvim" bash nvim-modern/tests/integration.sh
```

Offline tests cover local TypeScript selection, native vs legacy fallback,
workspace boundaries, guide filtering, action execution, and reminder controls.
`tests/integration.sh` prepares disposable Lua, legacy TypeScript, and Effect
projects, applies Effect patches only to their test dependencies, and runs the
full editor through its actual startup lifecycle. It checks parser/text-object
editing, searchable actions with preserved visual selections, automatic LSP
installation, formatting, FFF UI/file/content search,
legacy local TypeScript selection, real Effect diagnostics and type-aware
Oxlint without duplicates. It never patches or changes a real project.

Neovim references: `:help $NVIM_APPNAME`, `standard-path`, `vim.pack`,
`vim.pack-events`, `lsp-defaults`, `vim.lsp.config()`, `vim.lsp.enable()`,
`vim.lsp.buf.code_action()`, `treesitter-defaults`, `vim.treesitter.start()`,
`vim.fs.root()`, `vim.diagnostic.config()`, `news-breaking`.
Plugin options were checked against their current documentation/source.
