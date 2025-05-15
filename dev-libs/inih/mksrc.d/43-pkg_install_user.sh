#!/bin/sh
# -static +static-libs -shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="inih (INI not invented here) simple .INI file parser"
HOMEPAGE="https://github.com/benhoyt/inih"
LICENSE="BSD-3-Clause"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 "${ED}"/$(get_libdir)/ "${ED}"/usr/include/${PN}/
mv -n lib${PN}.* -t "${ED}"/$(get_libdir)/ &&
mv -n *.h cpp/*.h "${ED}"/usr/include/${PN}/ &&

printf %s\\n "Install: ${PN}... ok"
