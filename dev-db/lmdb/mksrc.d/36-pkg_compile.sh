#!/bin/sh
# -static +static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit flag-o-matic multilib multilib-minimal toolchain-funcs install-functions

DESCRIPTION="An ultra-fast, ultra-compact key-value embedded data store"
HOMEPAGE="https://symas.com/lmdb/technical/"
LICENSE="OPENLDAP"
IUSE="+static-libs"
EPREFIX=${EPREFIX:-$SPREFIX}
FILESDIR=${FILESDIR:-$DISTSOURCE}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}
local soname="-Wl,-soname,liblmdb$(get_libname)"

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

sed \
  -e "s!^CC.*!CC = ${CC}!" \
  -e "s!^CFLAGS.*!CFLAGS = ${CFLAGS}!" \
  -e "s!^AR.*!AR = ar!" \
  -e "s!^SOEXT.*!SOEXT = $(get_libname)!" \
  -e "/^prefix/s!/usr/local!${EPREFIX}/usr!" \
  -e "/^exec_prefix/s! \$(prefix)!!" \
  -e "/^libdir/s!lib\$!$(get_libdir)!" \
  -e "s!shared!shared ${soname}!" \
  -i "Makefile" || die

make V='0' -j"$(nproc)" LDLIBS+=" -pthread" || die "Failed make build"

make DESTDIR=${ED} install || die "make install... error"

dosym liblmdb$(get_libname) /$(get_libdir)/liblmdb$(get_libname 0)

insinto /$(get_libdir)/pkgconfig
doins "${FILESDIR}/lmdb.pc"
sed \
  -e "s!@PACKAGE_VERSION@!${PV}!" \
  -e "s!@prefix@!${EPREFIX}/usr!g" \
  -e "s!^exec_prefix=.*!exec_prefix=!g" \
  -e "s!\${prefix}/@libdir@!/$(get_libdir)!" \
  -i "${ED}"/$(get_libdir)/pkgconfig/lmdb.pc || die

if ! use 'static-libs'; then
  rm -- "${ED}"/$(get_libdir)/liblmdb.a || die
fi

rm -- Makefile

printf %s\\n "Install: ${PN}"
