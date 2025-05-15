#!/bin/sh
# -static +static-libs +shared +nopie -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Library parsing Microsoft Publisher documents"
HOMEPAGE="https://wiki.documentfoundation.org/DLP/Libraries/libmspub"
LICENSE="LGPL-2.1"
IUSE="-doc -tools +static-libs +shared +nopie (+musl) +stest +strip"

#append-ldflags "-static-libgcc" "-static-libstdc++"

# bug 619044
append-cxxflags -std=c++14

MYCONF="${MYCONF}
 --disable-werror
 --without-docs
 --disable-tools  # FIX: ld: final link failed: bad value
"