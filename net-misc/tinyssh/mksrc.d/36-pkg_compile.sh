#!/bin/sh
# +static -static-libs -shared -lfs -upx +patch -doc -man -xstub +diet -musl +stest +strip +x32

inherit toolchain-funcs install-functions

DESCRIPTION="A small SSH server with state-of-the-art cryptography"
HOMEPAGE="https://tinyssh.org"
LICENSE="CC0-1.0"
IUSE="-sodium"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

# Use make-tinysshcc.sh script, which has no tests and doesn't execute
# binaries. See https://github.com/janmojzis/tinyssh/issues/2
sed -i 's/make-tinyssh\.sh/make-tinysshcc.sh/g' ./Makefile || die

if use 'sodium'; then
  make V='0' -j"$(nproc)" \
    CC="${CC}" \
    LIBS="$(${PKG_CONFIG} --libs libsodium)" \
    CFLAGS="${CFLAGS} $(${PKG_CONFIG} --cflags libsodium)" \
    LDFLAGS="${LDFLAGS}" \
    || die "Failed make build"
else
  make V='0' -j"$(nproc)" CC="${CC}" || die "Failed make build"
fi

rm -- Makefile

dosbin build/bin/tinysshd
ln -s tinysshd "${ED}"/sbin/tinysshd-makekey
ln -s tinysshd "${ED}"/sbin/tinysshd-printkey
ln -s tinysshd "${ED}"/sbin/tinysshnoneauthd
doman man/*

printf %s\\n "Install: ${PN}"
