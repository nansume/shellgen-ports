# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Internationalized text layout and rendering library"
HOMEPAGE="http://www.pango.org/"
LICENSE="LGPL-2+ FTL"
IUSE="+X -introspection -test"
EPREFIX=${EPREFIX:-$SPREFIX}
FILESDIR=${FILESDIR:-$DISTSOURCE}

MYCONF="${MYCONF}
 --with-cairo
 --with-xft
 --x-includes="${EPREFIX%/}/usr/include"
 --x-libraries="${EPREFIX%/}/$(get_libdir)"
"

test "X${USER}" != 'Xroot' || return 0

cp -v "${FILESDIR}"/${PV}-pango-view.1.in "${BUILD_DIR}/utils/pango-view.1.in" || die
