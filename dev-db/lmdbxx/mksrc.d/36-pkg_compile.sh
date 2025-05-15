#!/bin/sh
# -static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet -musl -stest -strip +noarch

inherit install-functions

DESCRIPTION="C++11 wrapper for the LMDB database library"
HOMEPAGE="https://github.com/hoytech/lmdbxx"
LICENSE="public-domain"
IUSE="-test"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

make V='0' -j"$(nproc)" || die "Failed make build"

make PREFIX="${ED}/usr" install || die "make install... error"
dodoc AUTHORS CREDITS INSTALL README.md TODO UNLICENSE

rm -- Makefile

printf %s\\n "Install: ${PN}"
