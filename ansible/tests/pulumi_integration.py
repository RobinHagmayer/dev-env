"""Opt-in role-boundary checks using cached official archives and disposable homes.

Run with the project's Python; see tests/README.md. No sudo or production seams.
"""
import hashlib
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile
import unittest

ANSIBLE = Path(__file__).resolve().parents[1]
CACHE = Path(os.environ.get("PULUMI_TEST_CACHE", Path.home() / ".cache/ansible-downloads"))
CURRENT = "3.268.0"
PREVIOUS = "3.267.0"
DIGESTS = {
    CURRENT: "903cafeaa9f6327e4bf53a8b7b99ae660f26198acfa804a2f982bf5de3f1de0b",
    PREVIOUS: "527c1ce7c16cb38525a96d55422f221e819476e2b0743ae55c9862ad775ae10a",
}


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def snapshot(root):
    """Observe disk state, including logs and modes, without executing the CLI."""
    return {
        str(p.relative_to(root)): (
            p.lstat().st_mode, p.lstat().st_size, p.lstat().st_mtime_ns,
            os.readlink(p) if p.is_symlink() else None,
        )
        for p in [root, *root.rglob("*")]
    }


class PulumiIntegration(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        for version, expected in DIGESTS.items():
            archive = CACHE / f"pulumi-v{version}-linux-x64.tar.gz"
            if not archive.is_file() or digest(archive) != expected:
                raise RuntimeError(f"Supply the verified official archive: {archive}")

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="pulumi-integration-")
        self.root = Path(self.temp.name)
        self.user = self.root / "user"
        self.user.mkdir()
        self.home = self.user / ".local/share/pulumi"
        self.cache = self.root / "cache"
        self.cache.mkdir()
        for version in DIGESTS:
            shutil.copy2(CACHE / f"pulumi-v{version}-linux-x64.tar.gz",
                         self.cache / f"pulumi-v{version}-linux-x64.tar.gz")
        self.environment = self.root / "env"
        self.log_number = 0
        self.addCleanup(self.temp.cleanup)

    def run_role(self, version=CURRENT, checksum=None, check=False, success=True):
        play = [{
            "name": "Exercise the real Pulumi role",
            "hosts": "localhost",
            "connection": "local",
            "gather_facts": True,
            "vars": {
                "ansible_python_interpreter": str(ANSIBLE / ".venv/bin/python"),
                "manage_system_packages": False,
                "ansible_become_exe": "/bin/false",
                "pulumi_version": version,
                "pulumi_sha256": checksum or DIGESTS[version],
                "pulumi_home": str(self.home),
                "pulumi_download_dir": str(self.cache),
                "pulumi_environment_dir": str(self.environment),
            },
            "tasks": [
                # Isolate the legacy path too, without adding test-only role variables.
                {"name": "Use the disposable user home", "ansible.builtin.set_fact": {
                    "ansible_facts": "{{ ansible_facts | combine({'user_dir': '" + str(self.user) + "'}) }}"
                }},
                {"name": "Run the production role", "ansible.builtin.include_role": {"name": "pulumi"}},
            ],
        }]
        playbook = self.root / "playbook.json"
        playbook.write_text(json.dumps(play))
        args = [
            str(ANSIBLE / ".venv/bin/ansible-playbook"), str(playbook)
        ]
        if check:
            args.append("--check")
        result = subprocess.run(args, cwd=ANSIBLE, capture_output=True, text=True)
        output = result.stdout + result.stderr
        self.log_number += 1
        (self.root / f"run-{self.log_number}.log").write_text(output)
        self.assertEqual(result.returncode == 0, success, output)
        return output

    def cli_version(self):
        result = subprocess.run(
            [str(self.home / "bin/pulumi"), "version"],
            env={**os.environ, "PULUMI_HOME": str(self.home)},
            capture_output=True, text=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.strip()

    def seed_runtime(self):
        self.home.mkdir(parents=True, exist_ok=True)
        sentinel = self.home / "credentials.json"
        sentinel.write_text('{"sentinel": "must survive"}\n')
        return sentinel, sentinel.read_bytes()

    def assert_no_changes(self, output):
        recap = output.split("PLAY RECAP")[-1]
        self.assertRegex(recap, r"changed=0\b")

    def archive_fixture(self, script):
        archive = self.cache / f"pulumi-v{CURRENT}-linux-x64.tar.gz"
        archive.unlink()
        with tarfile.open(archive, "w:gz") as bundle:
            payload = script.encode()
            member = tarfile.TarInfo("pulumi/pulumi")
            member.mode = 0o755
            member.size = len(payload)
            bundle.addfile(member, io.BytesIO(payload))
        return digest(archive)

    def test_lifecycle_and_check_mode_preserve_disk_state(self):
        before = snapshot(self.user)
        self.run_role(check=True)
        self.assertEqual(snapshot(self.user), before)
        self.assertFalse(self.environment.exists())

        # Install older -> upgrade -> downgrade through the real official binaries.
        sentinel, content = self.seed_runtime()
        self.run_role(PREVIOUS)
        self.assertEqual(self.cli_version(), "v" + PREVIOUS)
        original_bundle = (self.home / "bin").resolve()
        original_hash = digest(original_bundle / "pulumi")

        before = snapshot(self.home)
        before_env = snapshot(self.environment)
        self.assert_no_changes(self.run_role(PREVIOUS, check=True))
        self.assertEqual(snapshot(self.home), before)
        self.assertEqual(snapshot(self.environment), before_env)
        self.assert_no_changes(self.run_role(PREVIOUS))

        self.run_role(CURRENT)
        upgraded_bundle = (self.home / "bin").resolve()
        self.assertEqual(self.cli_version(), "v" + CURRENT)
        self.assertEqual(digest(original_bundle / "pulumi"), original_hash)
        self.run_role(PREVIOUS)
        self.assertEqual(self.cli_version(), "v" + PREVIOUS)
        self.assertTrue(upgraded_bundle.is_dir())
        self.assertTrue(original_bundle.is_dir())
        self.assertEqual(sentinel.read_bytes(), content)

    def test_repairs_missing_modified_and_nonexecutable_helpers(self):
        self.run_role()
        helper = "pulumi-language-yaml"
        for damage in ("missing", "modified", "nonexecutable"):
            with self.subTest(damage=damage):
                selected = (self.home / "bin").resolve()
                path = selected / helper
                expected = digest(path)
                if damage == "missing":
                    path.unlink()
                elif damage == "modified":
                    with path.open("ab") as stream:
                        stream.write(b"corruption")
                else:
                    path.chmod(0o644)
                self.run_role()
                repaired = (self.home / "bin").resolve()
                self.assertNotEqual(selected, repaired)
                self.assertTrue(selected.is_dir())
                self.assertEqual(digest(repaired / helper), expected)
                self.assertTrue(os.access(repaired / helper, os.X_OK))
        self.assert_no_changes(self.run_role())

    def test_checksum_change_is_not_ignored(self):
        self.run_role()
        selected = (self.home / "bin").resolve()
        # A changed identity must trigger archive validation, even at the same version.
        output = self.run_role(checksum="0" * 64, success=False)
        self.assertIn("checksum", output.lower())
        self.assertEqual((self.home / "bin").resolve(), selected)
        self.assertEqual(self.cli_version(), "v" + CURRENT)

    def test_nonzero_candidate_exit_never_replaces_working_directory(self):
        (self.home / "bin").mkdir(parents=True)
        old = self.home / "bin/pulumi"
        old.write_text("#!/bin/sh\necho v3.267.0\n")
        old.chmod(0o755)
        old_content = old.read_bytes()
        checksum = self.archive_fixture("#!/bin/sh\necho v3.268.0\nexit 1\n")
        self.run_role(checksum=checksum, success=False)
        self.assertFalse((self.home / "bin").is_symlink())
        self.assertEqual(old.read_bytes(), old_content)
        self.assertEqual(self.cli_version(), "v" + PREVIOUS)
        self.assertEqual(list((self.home / "releases").iterdir()), [])

    def test_nonzero_selected_exit_is_reported_as_failure(self):
        # Candidate verification succeeds once; selected verification then fails
        # with identical stdout. This guards the post-selection exit check.
        checksum = self.archive_fixture(
            '#!/bin/sh\necho v3.268.0\n'
            'test ! -e "$PULUMI_HOME/verified-once" || exit 1\n'
            ': > "$PULUMI_HOME/verified-once"\n'
        )
        self.run_role(checksum=checksum, success=False)
        self.assertTrue((self.home / "bin").is_symlink())
        self.assertFalse(self.environment.exists())

    def test_selection_failure_preserves_active_symlink_and_verified_candidate(self):
        if os.geteuid() == 0:
            self.skipTest("Permission-denial recovery requires a non-root user")
        old = self.home / "old/bin"
        old.mkdir(parents=True)
        (old / "pulumi").write_text("#!/bin/sh\necho v3.267.0\n")
        (old / "pulumi").chmod(0o755)
        (self.home / "bin").symlink_to(old, target_is_directory=True)
        checksum = self.archive_fixture(
            '#!/bin/sh\nchmod 500 "$PULUMI_HOME"\necho v3.268.0\n'
        )
        try:
            self.run_role(checksum=checksum, success=False)
        finally:
            self.home.chmod(0o700)
        self.assertEqual((self.home / "bin").resolve(), old)
        self.assertEqual(self.cli_version(), "v" + PREVIOUS)
        # Observe retained executable content, not the role's directory naming.
        candidates = [p for p in self.home.rglob("pulumi") if p.parent != old]
        self.assertEqual(len(candidates), 1)
        self.assertTrue(candidates[0].is_file())

    def test_legacy_home_and_unmanaged_binaries_are_retained(self):
        legacy = self.user / ".pulumi"
        with tarfile.open(CACHE / f"pulumi-v{CURRENT}-linux-x64.tar.gz") as archive:
            archive.extractall(legacy, filter="data")
        (legacy / "pulumi").rename(legacy / "bin")
        (legacy / "credentials.json").write_text("preserve credentials")
        original_hash = digest(legacy / "bin/pulumi")
        before = snapshot(legacy)
        self.run_role(check=True)
        self.assertEqual(snapshot(legacy), before)
        self.assertFalse(self.home.exists())
        self.run_role()
        self.assertFalse(legacy.exists())
        self.assertTrue((self.home / "bin").is_symlink())
        retained = list((self.home / "releases").glob("legacy-*/bin/pulumi"))
        self.assertEqual(len(retained), 1)
        self.assertEqual(digest(retained[0]), original_hash)
        self.assertEqual((self.home / "credentials.json").read_text(), "preserve credentials")
        self.assertEqual(self.cli_version(), "v" + CURRENT)


if __name__ == "__main__":
    unittest.main(verbosity=2)
