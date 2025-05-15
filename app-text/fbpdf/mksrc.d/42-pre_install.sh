#!/bin/sh
# -static -static-libs +shared +nopie -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="framebuffer pdf and djvu viewer"
HOMEPAGE="https://github.com/aligrudi/fbpdf"
LICENSE="BSD ISC"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
PROGS="${PN} fbdjvu"

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

mkdir -pm 0755 -- "${ED}"/bin/
mv -n ${PROGS} -t "${ED}"/bin/ &&
printf %s\\n "Install: ${PROGS} bin/"
