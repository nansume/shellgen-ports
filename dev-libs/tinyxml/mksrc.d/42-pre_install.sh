#!/bin/sh
# -static +static-libs +shared -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Simple and small C++ XML parser"
HOMEPAGE="http://www.grinninglizard.com/tinyxml/index.html"
LICENSE="ZLIB"
IUSE="-debug -doc +static-libs +stl -stl"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

test "X${USER:?}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

mkdir -pm 0755 "${ED}"/$(get_libdir)/ "${ED}"/usr/include/${PN}/ "${ED}"/usr/share/pkgconfig
#mv -n xmltest "${ED}"/$(get_libdir)/lib${PN}.so &&
mv -n lib${PN}.[sa]* "${ED}"/$(get_libdir)/ &&
mv -n *.h "${ED}"/usr/include/${PN}/ &&
mv -n ${PN}.pc "${ED}"/usr/share/pkgconfig/ &&
printf %s\\n "Install: xmltest -> lib${PN}.so"

sed -i \
  -e "1s|^prefix=.*|prefix=|;t" \
  -e "3s|^libdir=.*|libdir=/$(get_libdir)|;t" \
  -e "4s|^includedir=.*|includedir=/usr/include/${PN}|;t" \
  ${ED}/usr/share/pkgconfig/${PN}.pc
