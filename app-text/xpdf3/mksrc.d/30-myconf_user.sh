# -static -static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="The PDF viewer and tools"
HOMEPAGE="https://www.xpdfreader.com"
LICENSE="|| ( GPL-2 GPL-3 ) i18n? ( BSD )"
IUSE="-cmyk -cups +fontconfig -i18n -icons +libpaper metric opi +png +textselect +utils"

MYCONF="${MYCONF}
 --with-freetype2-library=/$(get_libdir)
 --with-freetype2-includes=/usr/include/freetype2
"
