# Copyright(c) The Maintainers of Nanvix.
# Licensed under the MIT License.

"""Nanvix build script for numpy C extensions.

Usage:
    ./z setup      # Download Nanvix sysroot and CPython headers
    ./z build      # Cross-compile numpy multiarray_umath module
    ./z test       # (no-op — tested via nanvix-python)
    ./z release    # Package libnumpy.a release tarball
    ./z clean      # Remove build artifacts
    ./z distclean  # Deep clean
"""

import os
import shutil
import subprocess
import sys
from pathlib import Path

from nanvix_zutil import ZScript, log


class NumpyBuild(ZScript):
    """Build script for nanvix/numpy."""

    SYSROOT_REQUIRED_FILES: tuple[str, ...] = (
        "lib/libposix.a",
        "lib/user.ld",
    )

    @property
    def _nanvix_port_dir(self) -> Path:
        return self.repo_root / "nanvix-port"

    @property
    def _dist_dir(self) -> Path:
        return self._nanvix_port_dir / "dist"

    def setup(self) -> bool:
        ok = super().setup()
        if not ok:
            return False
        log.info("setup complete")
        return True

    def build(self) -> None:
        log.info("cross-compiling numpy C extensions...")
        script = self._nanvix_port_dir / "build-nanvix.sh"
        if not script.is_file():
            log.error(f"build script not found: {script}")
            sys.exit(1)

        env = os.environ.copy()
        env.setdefault("NANVIX_TOOLCHAIN", "/opt/nanvix")

        subprocess.run(
            ["bash", str(script)],
            cwd=str(self._nanvix_port_dir),
            env=env,
            check=True,
        )

        lib = self._dist_dir / "libnumpy.a"
        if lib.is_file():
            log.info(f"build complete: {lib} ({lib.stat().st_size // 1024} KB)")
        else:
            log.error("build failed: libnumpy.a not found")
            sys.exit(1)

    def test(self) -> None:
        log.info("numpy extensions are tested via nanvix-python — skipping")

    def release(self) -> None:
        import tarfile

        lib = self._dist_dir / "libnumpy.a"
        if not lib.is_file():
            log.error("libnumpy.a not found — run ./z build first")
            sys.exit(1)

        platform = os.environ.get("NANVIX_MACHINE", "microvm")
        memory = os.environ.get("NANVIX_MEMORY_SIZE", "256mb")
        tag = f"numpy-{platform}-standalone-{memory}"
        tarball = self._dist_dir / f"{tag}.tar.gz"

        with tarfile.open(tarball, "w:gz") as tf:
            tf.add(lib, arcname=f"{tag}/lib/libnumpy.a")

        log.info(f"release: {tarball} ({tarball.stat().st_size // 1024} KB)")

    def clean(self) -> None:
        if self._dist_dir.is_dir():
            shutil.rmtree(self._dist_dir)
            log.info("cleaned dist/")
        builddir = self.repo_root / "builddir"
        if builddir.is_dir():
            shutil.rmtree(builddir)
            log.info("cleaned builddir/")
