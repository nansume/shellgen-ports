#!/bin/sh
# -static -static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="youtube-dl fork with additional features and fixes"
HOMEPAGE="https://github.com/yt-dlp/yt-dlp/"
LICENSE="Unlicense"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

printf %s\\n "ln -s ${PN}.sh ${PN}"
ln -s ${PN}.sh ${PN}