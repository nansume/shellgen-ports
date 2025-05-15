#!/bin/sh
# +static +static-libs -shared -upx -patch -doc -xstub +diet -musl +stest +strip +x32

DESCRIPTION="The best variant of the Yacc parser generator"
HOMEPAGE="https://invisible-island.net/byacc/byacc.html"
LICENSE="public-domain"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
PROGS=${PN#b}

test "X${USER:?}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

mkdir -pm 0755 "${ED}"/bin/
mv -n ${PROGS} "${ED}"/bin/${PN} &&
printf %s\\n "Install: ${PN} bin/"
