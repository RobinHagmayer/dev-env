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

Install the developer tools (Rust, Go, Zig, pnpm) on this machine:

```sh
uv run ansible-playbook playbooks/dev-tools.yml --ask-become-pass
```

`--ask-become-pass` is only needed for the `base` play (apt packages). Run a subset with tags:

```sh
uv run ansible-playbook playbooks/dev-tools.yml --tags go,zig
uv run ansible-playbook playbooks/dev-tools.yml --skip-tags base
```

Tool versions are pinned in `roles/<role>/defaults/main.yml`. Go and Zig also pin a sha256 checksum, so update both when bumping a version.

Lint: `uv run ansible-lint`
