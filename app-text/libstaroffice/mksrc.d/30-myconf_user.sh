#!/bin/sh
# -static -static-libs +shared +nopie -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

: inherit autotools install-functions

DESCRIPTION="Import filter for old StarOffice documents"
HOMEPAGE="https://github.com/fosnola/libstaroffice"
LICENSE="|| ( LGPL-2.1+ MPL-2.0 )"
IUSE="-debug -doc -tools +zlib -static-libs +shared +nopie (+musl) +stest +strip"


append-ldflags "-static-libgcc" "-static-libstdc++"

MYCONF="${MYCONF}
 #--enable-static-tools
 --disable-debug
 --without-docs
 --disable-tools  # FIX: ld: final link failed: bad value
 $(use_enable zlib zip)
"