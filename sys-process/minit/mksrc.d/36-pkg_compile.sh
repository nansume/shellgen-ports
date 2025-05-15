#!/bin/sh
# +static -static-libs -shared -upx +patch -doc -man -xstub +diet -musl +stest +strip +x32

inherit toolchain-funcs

DESCRIPTION="a small yet feature-complete init"
HOMEPAGE="http://www.fefe.de/minit/"
LICENSE="GPL-2"
EPREFIX=${EPREFIX:-$SPREFIX}
FILESDIR=${FILESDIR:-$DISTSOURCE}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

make V='0' -j"$(nproc)" \
  CFLAGS="${CFLAGS} -I/usr/include/libowfat" \
  LDFLAGS="${LDFLAGS}" \
  || die "Failed make build"

make DESTDIR=${ED} install-files || die "make install... error"

rm -- Makefile

mv -n "${ED}"/sbin/shutdown "${ED}/sbin/${PN}-shutdown" || die
mv -n "${ED}"/sbin/killall5 "${ED}/sbin/${PN}-killall5" || die
rm -v -- "${ED}"/sbin/init || die

[ -e "/etc/minit/in" ] || mkfifo "${ED}"/etc/minit/in
[ -e "/etc/minit/out" ] || mkfifo "${ED}"/etc/minit/out

printf %s\\n "Install: ${PN}"
