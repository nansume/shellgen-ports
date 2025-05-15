#!/bin/sh
# -static +static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit autotools install-functions

DESCRIPTION="Set of command-line programs providing a simple interface to inotify"
HOMEPAGE="https://github.com/inotify-tools/inotify-tools/"
LICENSE="GPL-2"
IUSE="-doc"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

sed 's/ -Werror//' -i src/Makefile.am libinotifytools/src/Makefile.am || die  #745069

autoreconf --install
