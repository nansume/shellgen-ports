#!/bin/sh
# -static -static-libs +shared -nopie -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Backport of pathlib-compatible object wrapper for zip files"

HOMEPAGE="https://github.com/jaraco/zipp/ https://pypi.org/project/zipp/"
LICENSE="MIT"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

# write a custom pyproject.toml to ease setuptools bootstrap
cat > pyproject.toml <<-EOF || die
[build-system]
requires = ["flit_core >=3.2,<4"]
build-backend = "flit_core.buildapi"

[project]
name = "zipp"
version = "${PV}"
description = "Backport of pathlib-compatible object wrapper for zip files"
EOF