#!/bin/sh
# +static -static-libs -shared -lfs -upx +patch -doc -man -xstub +diet -musl +stest +strip +x32

inherit toolchain-funcs install-functions

DESCRIPTION="a fast, small and simple init with support for profiles"
HOMEPAGE="http://linux.schottelius.org/cinit/"
LICENSE="GPL-2"
IUSE="-doc"
EPREFIX=${EPREFIX:-$SPREFIX}
FILESDIR=${FILESDIR:-$DISTSOURCE}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX ED FILESDIR BUILD_DIR

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}; local D=${ED}

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

sed -i "/contrib+tools/d" Makefile || die
sed -i "/^STRIP/s/strip.*/true/" Makefile.include || die

make V='0' -j"$(nproc)" \
  CC="${CC}" \
  LD="${CC}" \
  CFLAGS="${CFLAGS} -I." \
  LDFLAGS="${LDFLAGS}" \
  STRIP="/bin/true" \
  all \
  || die "Failed make build"

make LD="${CC}" DESTDIR="${D}" install || die "make install... error"
rm -f "${D}"/sbin/{init,shutdown,reboot} || die
dodoc Changelog CHANGES CREDITS README TODO
use doc && dodoc -r doc

rm -- Makefile

printf %s\\n "Install: ${PN}"
