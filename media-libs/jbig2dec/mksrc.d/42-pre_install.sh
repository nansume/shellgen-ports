#!/bin/sh
# -static +static-libs -shared -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="A decoder implementation of the JBIG2 image compression format"
HOMEPAGE="https://jbig2dec.com/"
LICENSE="AGPL-3"
IUSE="-static +static-libs +shared -png -doc (+musl) -xstub +stest -test +strip"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
PROGS=${PN}

test "X${USER:?}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

mkdir -pm 0755 "${ED}"/bin/ "${ED}"/$(get_libdir)/ "${ED}"/usr/include/${PN}/
mv -n ${PROGS} bin/${PN} "${ED}"/bin/ &&
mv -n lib${PN}.[sa]* "${ED}"/$(get_libdir)/ &&
mv -n jbig2.h "${ED}"/usr/include/ &&
printf %s\\n "Install: ${PROGS} bin/"
