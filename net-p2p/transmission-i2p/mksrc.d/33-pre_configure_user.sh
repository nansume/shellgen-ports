#!/bin/sh
# https://www.linuxfromscratch.org/blfs/view/9.1/xsoft/transmission.html
# -static -static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

#inherit toolchain-funcs install-functions

DESCRIPTION="A fast, easy, and free BitTorrent client"
HOMEPAGE="https://transmissionbt.com/"
LICENSE="|| ( GPL-2 GPL-3 Transmission-OpenSSL-exception ) GPL-2 MIT"
IUSE="+cli -debug -gtk -nls (+mbedtls) -qt5 -systemd -test -doc (+musl) +stest +strip"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR="${BUILD_DIR:-$WORKDIR}"
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local EPREFIX=${EPREFIX%/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

test -x "/bin/perl" && autoreconf
