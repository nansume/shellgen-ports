# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Strictly RFC 3986 compliant URI parsing library in C"
HOMEPAGE="https://uriparser.github.io/"
LICENSE="BSD"
IUSE="-doc -qt5 -test +unicode"  # +doc to address warning RequiredUseDefaults
DOCS="AUTHORS ChangeLog THANKS"

CMAKEFLAGS="${CMAKEFLAGS}
 -DURIPARSER_BUILD_CHAR=ON
 -DURIPARSER_BUILD_DOCS=$(usex doc ON OFF)
 -DURIPARSER_BUILD_TESTS=$(usex test ON OFF)
 -DURIPARSER_BUILD_TOOLS=ON
 -DURIPARSER_BUILD_WCHAR_T=$(usex unicode ON OFF)
"

test "X${USER}" != 'Xroot' || return 0

rm -- configure
