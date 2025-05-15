#!/bin/sh
# -static -static-libs -shared +nopie -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32
# https://slackbuilds.org/repository/15.0/system/cdrkit/
# https://git.alpinelinux.org/aports/plain/community/cdrkit/
export PN PV BUILD_DIR

DESCRIPTION="Suite of programs for CD/DVD recording, ISO image creation, and audio CD extraction"
HOMEPAGE="http://cdrkit.org/"
LICENSE="GPL-2.0-only"
IUSE="-static -rpath -doc (+musl) -xstub +stest +strip"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

local IFS="$(printf '\n\t')"

test "X${USER}" != 'Xroot' || return 0
cd ${BUILD_DIR}/ || return

CMAKEFLAGS="\
  -DCMAKE_INSTALL_PREFIX=''
  -DCMAKE_SKIP_RPATH='ON'
  -DCMAKE_BUILD_TYPE='None'
  -Wno-dev
"

# disable rcmd, it is security risk and not implemented in musl
sed -e "s/#define HAVE_RCMD 1/#undef HAVE_RCMD/g" -i include/xconfig.h.in

append-cflags "-D__THROW=''"