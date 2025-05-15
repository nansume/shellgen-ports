#!/bin/sh
# +static -static-libs -shared -lfs -upx -patch -doc -man -xstub +diet -musl +stest +strip +x32

DESCRIPTION="A Linux utility to change the FSB frequency without having to reboot"
HOMEPAGE="https://sourceforge.net/projects/lfsb"
LICENSE="GPL-2"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
PROGS="src/${PN}"

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

mkdir -pm 0755 -- "${ED}"/sbin/
mv -n ${PROGS} -t "${ED}"/sbin/ &&
printf %s\\n "Install: ${PN}"
