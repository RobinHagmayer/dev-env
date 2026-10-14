"""Role-boundary checks with the official binary and disposable homes."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ANSIBLE = Path(__file__).resolve().parents[1]
VERSION = "1.0.2115+e16833f284"
SHA256 = "723d6aebdc226064aef321258fb17c8a2770c9cc2bd05004c0fb83e72b302c3f"
BINARY = Path(os.environ.get("DEVTUNNEL_TEST_BINARY", Path.home() / ".cache/ansible-downloads" /
                            f"devtunnel-{VERSION}-{SHA256}-linux-x64"))


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def snapshot(root):
    return {
        str(p.relative_to(root)): (
            p.lstat().st_mode, p.lstat().st_size, p.lstat().st_mtime_ns,
            os.readlink(p) if p.is_symlink() else None,
        )
        for p in [root, *root.rglob("*")]
    }


class DevTunnelIntegration(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        if not BINARY.is_file() or digest(BINARY) != SHA256:
            raise RuntimeError(f"Supply the verified official binary: {BINARY}")

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="devtunnel-integration-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.user = self.root / "user"
        self.user.mkdir()
        self.cache = self.root / "cache"
        self.downloads = self.cache / "ansible-downloads"
        self.downloads.mkdir(parents=True)
        self.install = self.user / ".local/opt/devtunnel"
        self.bin = self.user / ".local/bin"
        self.data = self.root / "data"
        self.data.mkdir()
        self.source = self.root / "official-binary"
        shutil.copy2(BINARY, self.source)
        self.env = {**os.environ, "HOME": str(self.user), "XDG_CACHE_HOME": str(self.cache),
                    "XDG_DATA_HOME": str(self.data), "XDG_CONFIG_HOME": str(self.root / "config"),
                    "ANSIBLE_HOME": str(self.root / "ansible"),
                    "ANSIBLE_LOCAL_TEMP": str(self.root / "ansible-local"),
                    "ANSIBLE_REMOTE_TEMP": str(self.root / "ansible-remote")}

    def run_role(self, check=False, checksum=SHA256, success=True):
        play = [{
            "name": "Exercise the real Dev Tunnels role",
            "hosts": "localhost",
            "connection": "local",
            "gather_facts": True,
            "vars": {
                "ansible_python_interpreter": str(ANSIBLE / ".venv/bin/python"),
                "manage_system_packages": False,
                "ansible_become_exe": "/bin/false",
                "devtunnel_install_dir": str(self.install),
                "devtunnel_bin_dir": str(self.bin),
                "devtunnel_url": self.source.as_uri(),
                "devtunnel_sha256": checksum,
            },
            "tasks": [
                {"name": "Use the disposable user home", "ansible.builtin.set_fact": {
                    "ansible_facts": "{{ ansible_facts | combine({'user_dir': '" + str(self.user) + "'}) }}"
                }},
                {"name": "Run the production role", "ansible.builtin.include_role": {"name": "devtunnel"}},
            ],
        }]
        playbook = self.root / "playbook.json"
        playbook.write_text(json.dumps(play))
        args = [str(ANSIBLE / ".venv/bin/ansible-playbook"), str(playbook)]
        if check:
            args.append("--check")
        result = subprocess.run(args, cwd=ANSIBLE, env=self.env, capture_output=True, text=True)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode == 0, success, output)
        return output

    def assert_no_changes(self, output):
        self.assertRegex(output.split("PLAY RECAP")[-1], r"changed=0\b")

    def test_lifecycle_repair_and_xdg_launcher(self):
        before = snapshot(self.user), snapshot(self.cache), snapshot(self.data)
        self.run_role(check=True)
        self.assertEqual((snapshot(self.user), snapshot(self.cache), snapshot(self.data)), before)

        self.run_role()
        selected = (self.install / "current").resolve()
        self.assertEqual(digest(selected / "devtunnel"), SHA256)
        self.assert_no_changes(self.run_role())
        before = snapshot(self.user), snapshot(self.cache), snapshot(self.data)
        self.assert_no_changes(self.run_role(check=True))
        self.assertEqual((snapshot(self.user), snapshot(self.cache), snapshot(self.data)), before)

        # Exercise the actual launcher: it must forward arguments and use XDG cache.
        runtime_cache = self.root / "runtime-cache"
        result = subprocess.run([str(self.bin / "devtunnel"), "--help"],
                                env={**self.env, "XDG_CACHE_HOME": str(runtime_cache)},
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Usage:", result.stdout)
        self.assertTrue(any((runtime_cache / "devtunnel/dotnet").rglob("*.dll")))
        self.assertFalse((self.user / ".net").exists())

        # Repair drift without editing the selected release in place.
        (selected / "devtunnel").write_bytes(b"corrupt")
        self.run_role()
        repaired = (self.install / "current").resolve()
        self.assertNotEqual(repaired, selected)
        self.assertEqual((selected / "devtunnel").read_bytes(), b"corrupt")
        self.assertEqual(digest(repaired / "devtunnel"), SHA256)
        (repaired / "devtunnel").chmod(0o644)
        self.run_role()
        self.assertNotEqual((self.install / "current").resolve(), repaired)
        self.assert_no_changes(self.run_role())

    def test_failed_candidates_preserve_working_installation(self):
        self.run_role()
        selected = (self.install / "current").resolve()
        launcher = (self.bin / "devtunnel").read_bytes()
        self.source.write_bytes(b"wrong download")
        self.run_role(checksum="0" * 64, success=False)
        self.assertEqual((self.install / "current").resolve(), selected)
        self.assertEqual(digest(selected / "devtunnel"), SHA256)

        # A matching version string cannot excuse a nonzero verification exit.
        self.source.write_text(f"#!/bin/sh\necho 'Tunnel CLI version: {VERSION}'\nexit 1\n")
        releases = set((self.install / "releases").iterdir())
        self.run_role(checksum=digest(self.source), success=False)
        self.assertEqual(set((self.install / "releases").iterdir()), releases)
        self.assertEqual((self.install / "current").resolve(), selected)
        self.assertEqual((self.bin / "devtunnel").read_bytes(), launcher)


if __name__ == "__main__":
    unittest.main()
