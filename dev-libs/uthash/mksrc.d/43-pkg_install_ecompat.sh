#!/bin/sh
# -static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet -musl -stest -strip +noarch

inherit toolchain-funcs install-functions

DESCRIPTION="An easy-to-use hash implementation for C programmers"
HOMEPAGE="https://troydhanson.github.io/uthash/index.html"
LICENSE="BSD-1"
IUSE="-test"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV ED BUILD_DIR

local IFS="$(printf '\n\t') "

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

doheader src/*.h
dodoc doc/*.txt

printf %s\\n "Install: ${PN}... ok"
