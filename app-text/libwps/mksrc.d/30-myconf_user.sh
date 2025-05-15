#!/bin/sh
# -static -static-libs +shared +nopie -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32


DESCRIPTION="Microsoft Works file word processor format import filter library"
HOMEPAGE="https://sourceforge.net/p/libwps/wiki/Home/"
LICENSE="|| ( LGPL-2.1 MPL-2.0 )"
IUSE="-debug -doc -tools -static-libs +shared +nopie (+musl) +stest +strip"

append-ldflags "-static-libgcc" "-static-libstdc++"

MYCONF="${MYCONF}
 #--enable-static-tools
 --disable-debug
 --without-docs
 --disable-tools  # ?FIX: ld: final link failed: bad value
"