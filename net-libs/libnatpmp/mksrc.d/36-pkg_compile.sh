#!/bin/sh
# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit toolchain-funcs install-functions

DESCRIPTION="An alternative protocol to UPnP IGD specification"
HOMEPAGE="http://miniupnp.free.fr/libnatpmp.html http://miniupnp.tuxfamily.org/libnatpmp.html"
LICENSE="BSD"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV BUILD_DIR ED

local IFS="$(printf '\n\t') "

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

sed \
  -e '/^INSTALLDIRBIN = / s|$(INSTALLPREFIX)|$(PREFIX)|' \
  -e '/^INSTALLDIRLIB = / s|$(INSTALLPREFIX)|$(PREFIX)|' \
  -i Makefile || die

make V='0' -j"$(nproc)" || die "Failed make build"

# Override HEADERS for missing declspec.h wrt #506832
make \
  _DESTDIR=${ED} \
  HEADERS="natpmp.h natpmp_declspec.h" \
  PREFIX="${ED}" \
  GENTOO_LIBDIR="$(get_libdir)" \
  install \
  || die "make install... error"

dodoc Changelog.txt README
doman natpmpc.1

rm -- Makefile

printf %s\\n "Install: ${PN}"
