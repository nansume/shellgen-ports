#!/bin/sh
# +static +static-libs -shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="A simple converter from OpenDocument Text to plain text"
HOMEPAGE="http://stosberg.net/odt2txt/"
LICENSE="GPL-2"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
PROGS=${PN}

test "X${USER:?}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

mkdir -pm 0755 "${ED}"/bin/
mv -n ${PROGS} -t "${ED}"/bin/ &&
printf %s\\n "Install: ${PROGS} bin/"
