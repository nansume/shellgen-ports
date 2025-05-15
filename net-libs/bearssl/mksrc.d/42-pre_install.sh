#!/bin/sh
# -static +static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Implementation of the SSL/TLS protocol in C"
HOMEPAGE="https://bearssl.org"
LICENSE="MIT"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

test "X${USER:?}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

mkdir -pm 0755 "${ED}"/bin/ "${ED}"/$(get_libdir)/ "${ED}"/usr/include/
mv -n build/brssl -t "${ED}"/bin/ &&
mv -n build/lib${PN}.a -t "${ED}"/$(get_libdir)/ &&
mv -n build/lib${PN}.so "${ED}"/$(get_libdir)/lib${PN}.so.${PV} &&
ln -s lib${PN}.so.${PV} "${ED}"/$(get_libdir)/lib${PN}.so.${PV%%.*} &&
ln -s lib${PN}.so.${PV} "${ED}"/$(get_libdir)/lib${PN}.so &&
mv -n inc/${PN}*.h "${ED}"/usr/include/ &&
mv -n LICENSE.txt "${ED}"/usr/share/doc/${PN}-${PV}/LICENSE &&
mv -n README.txt "${ED}"/usr/share/doc/${PN}-${PV}/README &&
printf %s\\n "Install: ${PROGS}"

rm -- Makefile
