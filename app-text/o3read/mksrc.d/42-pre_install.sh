#!/bin/sh
# +static +static-libs -shared -upx -patch -doc -xstub +diet -musl -stest +strip +x32

DESCRIPTION="Converts OpenOffice formats to text or HTML"
HOMEPAGE="http://siag.nu/o3read/"
LICENSE="GPL-2"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
PROGS="${PN} o3totxt o3tohtml utf8tolatin1"

test "X${USER:?}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

mkdir -pm 0755 "${ED}"/bin/
mv -n ${PROGS} -t "${ED}"/bin/ &&
printf %s\\n "Install: ${PROGS} bin/"
