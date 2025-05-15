#!/bin/sh
# -static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet -musl -stest -strip +x32

inherit install-functions

DESCRIPTION="Video Quirks database for pm-utils"
HOMEPAGE="https://pm-utils.freedesktop.org/"
LICENSE="GPL-2"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export ED BUILD_DIR

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

#insinto /$(get_libdir)/pm-utils
#doins -r video-quirks

insinto /lib/pm-utils
doins *.quirkdb

printf %s\\n "Install: ${PN}... ok"
