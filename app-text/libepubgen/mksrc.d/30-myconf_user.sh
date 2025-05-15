# -static -static-libs +shared +nopie -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="EPUB generator for librevenge"
HOMEPAGE="https://sourceforge.net/projects/libepubgen/"
LICENSE="MPL-2.0"
IUSE="-debug -doc -test"

MYCONF="${MYCONF}
 --disable-weffc
 --disable-debug
 --without-docs
 --disable-tests
"
