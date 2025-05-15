#!/bin/sh
# -static -static-libs +shared +nopie -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="C++ library to read and parse graphics in WPG"
HOMEPAGE="http://libwpg.sourceforge.net/libwpg.htm"
LICENSE="|| ( LGPL-2.1 MPL-2.0 )"
IUSE="-debug -doc -tools -static-libs +shared +nopie (+musl) +stest +strip"

append-ldflags "-static-libgcc" "-static-libstdc++"

MYCONF="${MYCONF}
 --disable-debug
 --without-docs
 --disable-tools  # ?FIX: ld: final link failed: bad value
"