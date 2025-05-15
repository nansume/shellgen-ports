#!/bin/sh
# +static +static-libs -shared -upx -patch -doc -xstub +diet -musl +stest +strip +x32

DESCRIPTION="Generate Encapsulated Postscript Format files from one-page Postscript documents"
HOMEPAGE="http://www.tm.uka.de/~bless/ps2eps"
LICENSE="GPL-2"
BUILD_DIR=${WORKDIR}
WORKDIR=${WORKDIR%/*/*}
ED=${INSTALL_DIR}
DESTDIR=${ED}
PROGS="bin/${PN} src/C/bbox"

test "X${USER:?}" != 'Xroot' || return 0

cd "${WORKDIR}/" || return

mkdir -pm 0755 "${DESTDIR}"/bin/
mv -n ${PROGS} -t "${ED}"/bin/
printf %s\\n "Install: ${PROGS} bin/"
