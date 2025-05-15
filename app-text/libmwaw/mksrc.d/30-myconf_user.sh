#!/bin/sh
# -static -static-libs +shared +nopie -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

: inherit autotools install-functions

DESCRIPTION="Library parsing many pre-OSX MAC text formats"
HOMEPAGE="https://sourceforge.net/p/libmwaw/wiki/Home/"
LICENSE="LGPL-2.1"
IUSE="-doc -tools +static-libs +shared +nopie (+musl) +stest (-test) +strip"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

export PN PV EPREFIX BUILD_DIR

local IFS="$(printf '\n\t')"; local EPREFIX=${EPREFIX%/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

append-ldflags "-static-libgcc" "-static-libstdc++"

MYCONF="${MYCONF}
 --without-docs
 --enable-zip
 --disable-werror
 --disable-tools
 #--enable-static-tools
"

test -x "/bin/perl" && autoreconf --install