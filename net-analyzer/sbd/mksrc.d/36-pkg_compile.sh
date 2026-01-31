#!/bin/sh
# +static -static-libs -shared -lfs -upx -patch -doc -man -xstub +diet -musl +stest +strip +x32

# http://gpo.zugaina.org/net-analyzer/sbd

inherit toolchain-funcs install-functions

DESCRIPTION="Netcat-clone, designed to be portable and offer strong encryption"
HOMEPAGE="http://tigerteam.se/dl/sbd/"
LICENSE="GPL-2+"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV BUILD_DIR ED

local IFS="$(printf '\n\t') "

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

sed \
  -e '/ -o /{ s| $(UNIX_LDFLAGS) $(LDFLAGS)||g;s|$(CFLAGS)|& $(LDFLAGS)|g }' \
  -i Makefile || die

make V='0' -j"$(nproc)" CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" unix || die "Failed make build"

dobin sbd
dodoc CHANGES README

rm -- Makefile

printf %s\\n "Install: ${PN}"
