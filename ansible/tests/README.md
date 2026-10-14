# Pulumi role integration checks

Run as a normal user on Linux x86_64, from `ansible/`:

```sh
PULUMI_TEST_CACHE="$HOME/.cache/ansible-downloads" .venv/bin/python tests/pulumi_integration.py
```

Supply the official `pulumi-v3.267.0-linux-x64.tar.gz` and
`pulumi-v3.268.0-linux-x64.tar.gz` archives in that cache first. The checks
validate their SHA256 digests before use; release assets are available under
`https://github.com/pulumi/pulumi/releases/download/v<VERSION>/<FILENAME>`.
These fixed adjacent releases are integration fixtures, not the role's version
defaults. The checks exercise the real Ansible role with disposable homes,
including the legacy home, and skip sudo package tasks. They do not install
anything into your real home. Normal host prerequisites must already be present.

Coverage: fresh install, upgrade/downgrade and retained releases, dry-run disk
state, rerun idempotency, full-bundle repair, changed checksum rejection,
nonzero verification exits, legacy migration, and failed symlink selection.
Tiny executable archives are used only for intentional runtime/permission
failures. The permission-denial case must run non-root.

No production-only test flags or hooks are added. Ansible logs are included in
assertion failures; temporary directories are cleaned up automatically.
