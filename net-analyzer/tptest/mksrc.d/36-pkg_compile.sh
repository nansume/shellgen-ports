#!/bin/sh
# +static -static-libs -shared -upx -patch -doc -man -xstub +diet -musl +stest +strip +x32

inherit toolchain-funcs install-functions

DESCRIPTION="Internet bandwidth tester"
HOMEPAGE="https://tptest.sourceforge.net/"
LICENSE="GPL-2"
EPREFIX=${EPREFIX:-$SPREFIX}
FILESDIR=${DISTSOURCE}
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-src"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-src"
ED=${ED:-$INSTALL_DIR}
PROGS=${PN}

export PN PV EPREFIX ED

local IFS="$(printf '\n\t') "
local EPREFIX=${EPREFIX%/}

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

patch -p1 -E < "${FILESDIR}/${PN}-3.1.7-getstatsfromlinevuln.patch"
patch -p1 -E < "${FILESDIR}/${PN}-3.1.7-clang16-build-fix.patch"

sed \
  -e "s:^CFLAGS[[:space:]]*=:CFLAGS+=:" \
  -i apps/unix/client/Makefile \
  -i apps/unix/server/Makefile \
  || die

cp -f os-dep/unix/* . || die
cp -f engine/* . || die

make V='0' -j"$(nproc)" -C apps/unix/client CC="${CC}" LDFLAGS="${LDFLAGS}" || die "Failed make build"
make V='0' -j"$(nproc)" -C apps/unix/server CC="${CC}" LDFLAGS="${LDFLAGS}" || die "Failed make build"

dobin apps/unix/client/tptestclient
dosbin apps/unix/server/tptestserver

insinto /etc
doins apps/unix/server/tptest.conf

printf %s\\n "Install: ${PROGS}"
