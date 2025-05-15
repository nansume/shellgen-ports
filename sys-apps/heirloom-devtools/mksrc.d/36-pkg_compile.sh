#!/bin/sh
# +static -static-libs -shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit toolchain-funcs install-functions

DESCRIPTION="Heirloom development tools -- original Unix tools"
HOMEPAGE="https://heirloom.sourceforge.net/devtools.html"
LICENSE="BSD-4 CDDL"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

test "X${USER}" != 'Xroot' || return 0

MAKEFLAGS="BINDIR=${EPREFIX}/bin/ccs"
MAKEFLAGS="${MAKEFLAGS} SUSBIN=${EPREFIX}/bin/5bin/posix"
MAKEFLAGS="${MAKEFLAGS} LIBDIR=${EPREFIX}/$(get_libdir)/ccs"
MAKEFLAGS="${MAKEFLAGS} AR=ar"
MAKEFLAGS="${MAKEFLAGS} RANLIB=ranlib"

cd "${BUILD_DIR}/" || return

make \
  "${MAKEFLAGS}" \
  CFLAGS="${CFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  SUBDIRS=yacc
make -j1 \
  "${MAKEFLAGS}" \
  CFLAGS="${CFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  SUBDIRS="lex m4"
make \
  "${MAKEFLAGS}" \
  CFLAGS="${CFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  makefiles
make \
  "${MAKEFLAGS}" \
  CFLAGS="${CFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  || die "Failed make build"

unset MAKEFLAGS

make \
  STRIP=true \
  INSTALL=install \
  ROOT="${ED}" \
  BINDIR="${EPREFIX}/bin/ccs" \
  SUSBIN="${EPREFIX}/bin/5bin/posix" \
  LIBDIR="${EPREFIX}/$(get_libdir)/ccs" \
  MANDIR="${EPREFIX}/usr/share/man/ccs" \
  install \
  || die "make install... error"

einstalldocs || true

rm -- makefile

printf %s\\n "Install: ${PN}"
