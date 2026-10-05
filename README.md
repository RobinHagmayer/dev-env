# ansible-playbooks

Personal Ansible playbooks.

## Prerequisites

Fresh Ubuntu LTS with `curl`, `git` and `openssh-client` (all usually preinstalled).

### 1. Install uv (manual step)

```sh
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Restart the shell and verify:

```sh
uv --version
```

uv manages its own Python, so the distro's `python3` is not used.

### 2. Install Ansible with uv

Ansible is a project dependency, so the version is pinned in `pyproject.toml` and `uv.lock`.

First-time setup of the project (only once, then commit the files):

```sh
uv init --bare
uv add ansible
```

On any other machine, after cloning:

```sh
uv sync
```

Verify:

```sh
uv run ansible --version
```

Run Ansible commands through `uv run`, e.g. `uv run ansible-playbook playbook.yml`.

## Usage

Install the base packages and developer tools (Rust, Go, Zig, pnpm + Node.js) on this machine:

```sh
uv run ansible-playbook playbooks/dev-tools.yml --ask-become-pass
```

Install Pi, Claude Code and Codex using their official installers:

```sh
uv run ansible-playbook playbooks/ai-tools.yml --ask-become-pass
```

Install only selected tools:

```sh
uv run ansible-playbook playbooks/ai-tools.yml --tags pi --ask-become-pass
uv run ansible-playbook playbooks/ai-tools.yml --tags claude,codex --ask-become-pass
```

These roles install as your normal user, skip existing binaries in `~/.local/bin`, and use each installer's default release rather than pinning versions. Pi pulls in the pnpm role for Node.js and npm. Installer scripts are downloaded into `~/.cache/ansible-installers` before execution; Codex is explicitly non-interactive, and Pi runs without a controlling terminal to prevent prompts or launching the app. A dry run does not download or execute these installers.

Reruns do not upgrade existing tools. Use `pi update`, `claude update`, or Codex's own update mechanism/re-run its official installer. Authentication is a separate manual step; no credentials are managed by these roles. Other installation locations/package managers are not automatically migrated. Make sure `~/.local/bin` is on your shell PATH, e.g. for the current terminal:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

Build and install Ghostty's current development (tip) version from its prepared source tarball (pulls in the Zig role):

```sh
uv run ansible-playbook playbooks/ghostty.yml --ask-become-pass
```

With `ghostty_version: "tip"` (the default), each run checks GitHub's tip release metadata, verifies the archive against its SHA256 digest, and rebuilds only when the source or build settings change or the binary is missing. New tip archives get separate cache/source paths to avoid reusing stale source. Tip requires internet access to GitHub, is subject to GitHub API rate limits, and is not a pinned/reproducible release. Old source/cache directories are retained. When building `gtk4-layer-shell` from source, the role uses `patchelf` to add `$ORIGIN/../lib` to Ghostty's library search path, so the installed binary finds its bundled library from both terminals and the desktop launcher. This repair also runs when no rebuild is needed.

To return to stable, set `ghostty_version` to a release such as `"1.3.1"` and set its matching `ghostty_sha256` (the saved default checksum is for 1.3.1). The Ghostty role passes its required Zig version/checksum to the Zig dependency. Current tip needs Zig 0.16.0 according to its `build.zig.zon` (the website still lists 0.15.2); stable 1.3.x uses 0.15.2. Tip's requirement may change; update `ghostty_zig_version` and `ghostty_zig_sha256` together, checking the source's `build.zig.zon` as well as the [build documentation](https://ghostty.org/docs/install/build).

Build Neovim from source and install it as a DEB package (so `dpkg`/`apt remove neovim` removes it cleanly):

```sh
uv run ansible-playbook playbooks/neovim.yml --ask-become-pass
```

Every role installs the system packages it needs itself (tasks tagged `packages`, run with sudo), so each role works on its own. Run a subset with tags, and skip the sudo tasks when the packages are already there:

```sh
uv run ansible-playbook playbooks/dev-tools.yml --tags go,zig --ask-become-pass
uv run ansible-playbook playbooks/dev-tools.yml --skip-tags packages
```

Tool versions are configured in `roles/<role>/defaults/main.yml`. Neovim is pinned by git tag. Go, Zig and stable Ghostty releases also pin a sha256 checksum, so update both when bumping a version. Ghostty tip instead resolves the current archive checksum from GitHub. Each Ghostty release needs one specific Zig version (`ghostty_zig_version`); the Ghostty role fails early if the installed Zig differs.

Rerunning Neovim checks the installed DEB version, so it reinstalls after `apt remove neovim` and applies version changes (including downgrades). Ghostty rebuilds when its binary is missing or its recorded build settings differ; existing version-only markers trigger a one-time rebuild. Rust ensures `rust_toolchain` is installed and selected as the default. The default `stable` follows a release channel rather than pinning a version; existing toolchains are updated manually with `rustup update`.

Lint: `uv run ansible-lint`
