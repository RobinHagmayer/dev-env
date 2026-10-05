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

Build and install Ghostty from source (pulls in the Zig role):

```sh
uv run ansible-playbook playbooks/ghostty.yml --ask-become-pass
```

Build Neovim from source and install it as a DEB package (so `dpkg`/`apt remove neovim` removes it cleanly):

```sh
uv run ansible-playbook playbooks/neovim.yml --ask-become-pass
```

Every role installs the system packages it needs itself (tasks tagged `packages`, run with sudo), so each role works on its own. Run a subset with tags, and skip the sudo tasks when the packages are already there:

```sh
uv run ansible-playbook playbooks/dev-tools.yml --tags go,zig --ask-become-pass
uv run ansible-playbook playbooks/dev-tools.yml --skip-tags packages
```

Tool versions are configured in `roles/<role>/defaults/main.yml`. Neovim is pinned by git tag. Go, Zig and Ghostty also pin a sha256 checksum, so update both when bumping a version. Each Ghostty release needs one specific Zig version (`ghostty_zig_version`); the Ghostty role fails early if the installed Zig differs.

Rerunning Neovim checks the installed DEB version, so it reinstalls after `apt remove neovim` and applies version changes (including downgrades). Ghostty rebuilds when its binary is missing or its recorded build settings differ; existing version-only markers trigger a one-time rebuild. Rust ensures `rust_toolchain` is installed and selected as the default. The default `stable` follows a release channel rather than pinning a version; existing toolchains are updated manually with `rustup update`.

Lint: `uv run ansible-lint`
