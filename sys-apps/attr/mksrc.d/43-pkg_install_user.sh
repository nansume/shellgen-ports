#!/bin/sh
# -static +static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Extended attributes tools"
HOMEPAGE="https://savannah.nongnu.org/projects/attr"
LICENSE="LGPL-2.1+"
IUSE="-debug -nls +static-libs"
FILESDIR=${DISTSOURCE}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mv -n ${FILESDIR}/xattr-shim.h -t "${ED}"/usr/include/${PN}/xattr.h &&
printf %s\\n "Install: usr/include/${PN}/xattr.h"
