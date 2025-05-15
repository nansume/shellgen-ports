#!/bin/sh
# -static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet -musl -stest -strip +noarch

inherit install-functions

DESCRIPTION="ultra fast, simple, secure & standards compliant web I/O"
HOMEPAGE="https://github.com/uNetworking/uWebSockets"
LICENSE="Apache-2.0"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export ED

local IFS="$(printf '\n\t') "

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

mv -n src uWebSockets
doheader -r uWebSockets

rm -- GNUmakefile Makefile

printf %s\\n "Install: ${PN}"
