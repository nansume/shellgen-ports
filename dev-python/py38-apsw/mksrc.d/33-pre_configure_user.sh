#!/bin/sh
# -static -static-libs +shared -nopie -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="APSW - Another Python SQLite Wrapper"
HOMEPAGE="https://github.com/rogerbinns/apsw/ https://pypi.org/project/apsw/"
LICENSE="ZLIB"
IUSE="-doc"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

cat >> setup.cfg <<-EOF || die
[build_ext]
enable=load_extension
use_system_sqlite_config=True
EOF