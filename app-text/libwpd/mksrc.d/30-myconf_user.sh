#!/bin/sh
# -static -static-libs +shared +nopie -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="WordPerfect Document import/export library"
HOMEPAGE="http://libwpd.sf.net"
LICENSE="|| ( LGPL-2.1 MPL-2.0 )"
IUSE="-doc -tools -static-libs +shared +nopie (+musl) +stest +strip"

append-ldflags "-static-libgcc" "-static-libstdc++"

MYCONF="${MYCONF}
 #--enable-static-tools
 --without-docs
 --disable-tools  # FIX: ld: final link failed: bad value
"