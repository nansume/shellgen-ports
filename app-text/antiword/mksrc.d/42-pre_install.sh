#!/bin/sh
# -static -static-libs -shared -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="free MS Word reader"
HOMEPAGE="http://www.winfield.demon.nl"
LICENSE="GPL-2"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
PROGS=${PN}

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

mkdir -pm 0755 "${ED}"/bin/
mv -n ${PROGS} "${ED}"/bin/ &&
printf %s\\n "Install: ${PROGS} bin/"
