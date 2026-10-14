# Role integration checks

## Pulumi

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

## Dev Tunnels

Run from `ansible/` with the verified official Linux x64 binary available:

```sh
DEVTUNNEL_TEST_BINARY=/path/to/linux-x64-devtunnel .venv/bin/python tests/devtunnel_integration.py
```

The fixed fixture is CLI build `1.0.2115+e16833f284`, SHA256
`723d6aebdc226064aef321258fb17c8a2770c9cc2bd05004c0fb83e72b302c3f`.
Its official download is:
`https://tunnelsassetsprod.blob.core.windows.net/cli/1.0.2115+e16833f284/linux-x64-devtunnel`.
By default the test looks in `~/.cache/ansible-downloads` using the role's
version/checksum-qualified filename.

The checks exercise the production role in disposable homes, skipping sudo
package tasks. Coverage includes fresh/check-mode disk state, idempotency,
content/permission repair with retained releases, real launcher argument
forwarding and custom XDG cache extraction, checksum failure, and rejection of
a matching version string with nonzero exit status. Verification of the real
binary contacts Microsoft's tunnel service; host prerequisites must exist.
Tests isolate CLI data and cache from your real home. No test-only production
hooks are used; fixture URLs use Ansible's normal file download support.
