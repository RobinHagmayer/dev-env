"""Exercise the isolated installer with a tiny real CMake build, not Neovim itself."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ANSIBLE = Path(__file__).resolve().parents[1]


class NeovimUserIntegration(unittest.TestCase):
    def test_user_build_and_dry_run_never_require_system_pin_or_sudo(self):
        with tempfile.TemporaryDirectory(prefix="neovim-user-integration-") as temp:
            root = Path(temp)
            repo = root / "upstream"
            repo.mkdir()
            # Real git/CMake/compiler/install boundaries; no production test hooks.
            (repo / "main.c").write_text("int main(void) { return 0; }\n")
            (repo / "CMakeLists.txt").write_text(
                "cmake_minimum_required(VERSION 3.16)\n"
                "project(installer_fixture C)\n"
                "add_executable(nvim main.c)\n"
                "install(TARGETS nvim DESTINATION bin)\n")
            (repo / "Makefile").write_text(
                "all:\n\tcmake -S . -B build -DCMAKE_INSTALL_PREFIX=$(CMAKE_INSTALL_PREFIX)\n"
                "\tcmake --build build\n"
                "distclean:\n\trm -rf build\n")
            for args in [["init", "-q"], ["add", "."],
                         ["-c", "user.name=Integration Test", "-c", "user.email=test@example.invalid",
                          "commit", "-qm", "Create build fixture"]]:
                subprocess.run(["git", "-C", str(repo), *args], check=True)
            commit = subprocess.check_output(
                ["git", "-C", str(repo), "rev-parse", "HEAD"], text=True).strip()
            prefix = root / "prefix"
            source = root / "source"
            play = [{
                "name": "Verify isolated Neovim installer without sudo",
                "hosts": "localhost",
                "connection": "local",
                "vars": {
                    "ansible_python_interpreter": str(ANSIBLE / ".venv/bin/python"),
                    "ansible_become_exe": "/bin/false",
                    "manage_system_packages": False,
                    "neovim_user_install": True,
                    "neovim_repo": str(repo),
                    "neovim_version": commit,
                    "neovim_src_dir": str(source),
                    "neovim_install_prefix": str(prefix),
                },
                "roles": ["neovim"],
            }]
            playbook = root / "playbook.json"
            playbook.write_text(json.dumps(play))
            env = {**os.environ, "ANSIBLE_HOME": str(root / "ansible"),
                   "ANSIBLE_LOCAL_TEMP": str(root / "local"),
                   "ANSIBLE_REMOTE_TEMP": str(root / "remote")}

            def run(check=False):
                args = [str(ANSIBLE / ".venv/bin/ansible-playbook"), str(playbook)]
                if check:
                    args.append("--check")
                result = subprocess.run(args, cwd=ANSIBLE, env=env,
                                        capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                return result.stdout

            run(check=True)
            self.assertFalse(prefix.exists())
            self.assertFalse(source.exists())
            run()
            binary = prefix / "bin/nvim"
            self.assertTrue(os.access(binary, os.X_OK))
            self.assertEqual(subprocess.run([str(binary)]).returncode, 0)
            self.assertEqual((prefix / ".build-signature").read_text(),
                             commit + ":RelWithDebInfo\n")
            before = binary.stat().st_mtime_ns
            self.assertRegex(run().split("PLAY RECAP")[-1], r"changed=0\b")
            self.assertRegex(run(check=True).split("PLAY RECAP")[-1], r"changed=0\b")
            self.assertEqual(binary.stat().st_mtime_ns, before)

            # A cached new pin is not sufficient: the source must switch to it.
            (repo / "main.c").write_text("int main(void) { return 0; } /* next pin */\n")
            subprocess.run(["git", "-C", str(repo), "add", "."], check=True)
            subprocess.run(["git", "-C", str(repo), "-c", "user.name=Integration Test",
                            "-c", "user.email=test@example.invalid", "commit", "-qm",
                            "Change source pin"], check=True)
            next_commit = subprocess.check_output(
                ["git", "-C", str(repo), "rev-parse", "HEAD"], text=True).strip()
            subprocess.run(["git", "-C", str(source), "fetch", "-q", "origin"], check=True)
            play[0]["vars"]["neovim_version"] = next_commit
            playbook.write_text(json.dumps(play))
            run()
            selected = subprocess.check_output(
                ["git", "-C", str(source), "rev-parse", "HEAD"], text=True).strip()
            self.assertEqual(selected, next_commit)
            self.assertEqual((prefix / ".build-signature").read_text(),
                             next_commit + ":RelWithDebInfo\n")
            self.assertRegex(run().split("PLAY RECAP")[-1], r"changed=0\b")


if __name__ == "__main__":
    unittest.main()
