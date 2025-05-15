#!/bin/sh
# +static -static-libs -shared -upx +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# https://git.alpinelinux.org/aports/plain/community/davfs2/APKBUILD

inherit autotools

DESCRIPTION="Linux FUSE (or coda) driver that allows you to mount a WebDAV resource"
HOMEPAGE="https://savannah.nongnu.org/projects/davfs2"
LICENSE="GPL-3+"
IUSE="-nls"
BUILD_DIR=${WORKDIR}

MYCONF="${MYCONF}
 --enable-largefile
"

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

autoreconf --install
