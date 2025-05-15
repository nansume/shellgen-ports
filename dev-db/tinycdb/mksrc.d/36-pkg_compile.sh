#!/bin/sh
# -static +static-libs +shared -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

export PN PV ED

inherit toolchain-funcs

local IFS="$(printf '\n\t') "
local EPREFIX=${SPREFIX%/}

DESCRIPTION="A very fast and simple package for creating and reading constant data bases"
HOMEPAGE="http://www.corpit.ru/mjt/tinycdb.html"
LICENSE="public-domain"
IUSE="+static-libs"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

sed -i "/^libdir/s:/lib:/$(get_libdir):" Makefile

make -j"$(nproc)" V='0' \
  CC="${CC}" \
  CFLAGS="${CFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  shared staticlib piclib \
  || die "Failed make build"

make \
  DESTDIR=${ED} \
  prefix="${EPREFIX}"/usr \
  exec_prefix="${EPREFIX}" \
  mandir="${EPREFIX}"/usr/share/man \
  install install-sharedlib install-piclib \
  || die "make install... error"

rm -- Makefile

einstalldocs

printf %s\\n "Install: ${PN}"
