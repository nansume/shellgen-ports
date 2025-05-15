#!/bin/sh
# -static +static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="A free stand-alone ini file parsing library"
HOMEPAGE="https://github.com/ndevilla/iniparser"
LICENSE="MIT"
IUSE="-doc -examples"
SLOT="3"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

local PN=${PN%[0-9]}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 "${ED}"/$(get_libdir)/ "${ED}"/usr/include/${PN}${SLOT}/

mv -n lib${PN}.* -t "${ED}"/$(get_libdir)/ &&
ln -s lib${PN}.so.0 "${ED}"/$(get_libdir)/lib${PN}.so.1.0.0 &&
ln -s lib${PN}.so.0 "${ED}"/$(get_libdir)/lib${PN}.so &&
mv -n src/*.h "${ED}"/usr/include/${PN}${SLOT}/ &&

printf %s\\n "Install: lib${PN}.a lib${PN}.so"
