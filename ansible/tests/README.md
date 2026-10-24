# Role checks

## Google Cloud CLI

```sh
uv run ansible-playbook tests/system-tool-pins.yml
uv run ansible-playbook tests/system-tool-pins.yml --check
```

The shared real-role pin rejection test includes Google Cloud CLI with
privilege escalation disabled. It protects the sudo-free boundary and
actionable bootstrap error; prerequisites must already be installed.

For apt lifecycle checks, use a disposable Debian/Ubuntu container, never the
host: mount this directory read-only at `/workspace`, install `ansible-core`,
`python3-debian`, `python3-apt` and `ca-certificates`, then run from `/workspace` as root:

```sh
ansible-playbook playbooks/gcloud.yml --check --diff
ansible-playbook playbooks/gcloud.yml
ansible-playbook playbooks/gcloud.yml
ansible-playbook playbooks/user-tools.yml --tags gcloud -e '{"ansible_become_exe":"/bin/false"}'
dpkg-query -W google-cloud-cli
apt-mark showhold
gcloud version
```

A fresh check must leave the package/repository absent (apt may fail to resolve
the pin because check mode does not create the repository); after installation the
second provisioning and sudo-free runs should report zero changes. Unhold the
package with `apt-mark unhold google-cloud-cli` and verify sudo-free validation
fails with the hold error, then rerun provisioning to repair it. Changing
`gcloud_version` to an available adjacent release exercises upgrade/downgrade;
an unavailable version must fail without changing the installed package.

## Sudo-free workflow

From `ansible/`, use installed tools to check the actual entry point:

```sh
uv run ansible-playbook playbooks/user-tools.yml --check -e '{"ansible_become_exe":"/bin/false"}'
uv run ansible-playbook playbooks/user-tools.yml --tags pulumi,devtunnel,neovim-modern -e '{"ansible_become_exe":"/bin/false"}'
```

The second command performs real reconciliation on your workstation; inspect
pins first; it is not sandboxed.
