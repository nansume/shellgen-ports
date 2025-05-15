# -static -static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Helper library for REVerse ENGineered formats filters"
HOMEPAGE="https://sourceforge.net/p/libwpd/librevenge/ci/master/tree/"
LICENSE="|| ( MPL-2.0 LGPL-2.1 )"
IUSE="-doc -test"

MYCONF="${MYCONF}
 $(use_enable 'test' tests)
"
