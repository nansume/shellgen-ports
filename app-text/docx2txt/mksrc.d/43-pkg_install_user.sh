#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -xstub -diet -musl +stest +strip +x32

DESCRIPTION="Convert MS Office docx files to plain text"
HOMEPAGE="http://docx2txt.sourceforge.net/"
LICENSE="GPL-3"
PROGS="${PN}.pl"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 "${ED}"/bin/
mv -n ${PROGS} "${ED}"/bin/${PN} &&
printf %s\\n "Install: ${PN} ${ED}/bin/"
