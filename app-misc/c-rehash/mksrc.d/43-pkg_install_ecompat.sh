#!/bin/sh
# -static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet -musl -stest -strip +noarch

inherit install-functions

DESCRIPTION="c_rehash script from OpenSSL"
HOMEPAGE="https://www.openssl.org/ https://github.com/pld-linux/openssl/"
LICENSE="openssl"
PV="1.7"
EPREFIX=${EPREFIX:-$SPREFIX}
FILESDIR=${FILESDIR:-$DISTSOURCE}
DISTDIR=${FILESDIR}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export ED BUILD_DIR

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

sed \
  -e "/^DIR=/s:=.*:=${EPREFIX}/etc/ssl:" \
  -e "s:SSL_CMD=/usr:SSL_CMD=${EPREFIX}/usr:" \
  "${DISTDIR}"/openssl-c_rehash.sh.${PV} \
  > c_rehash || die  #416717

dobin c_rehash || exit

printf %s\\n "Install: ${PN}... ok"
