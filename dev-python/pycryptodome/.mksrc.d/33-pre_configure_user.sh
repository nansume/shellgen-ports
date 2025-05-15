#!/bin/sh
# -static-libs +shared -nopie -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="A self-contained cryptographic library for Python"
HOMEPAGE="https://www.pycryptodome.org/ https://github.com/Legrandin/pycryptodome/"
LICENSE="BSD-2 Unlicense"
# required python[threads+]
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

# make sure we're unbundling it correctly
rm -r -- "src/libtom/" || die
