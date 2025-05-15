#!/bin/sh
# -static -static-libs -shared +nopie -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Heirloom Bourne Shell, derived from OpenSolaris code SVR4/SVID3"
HOMEPAGE="http://heirloom.sourceforge.net/sh.html"
LICENSE="CDDL"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

mkdir -pm 0755 -- "${ED}"/bin/
mv -n sh "${ED}"/bin/jsh &&
printf %s\\n "Install: ${PN}"
