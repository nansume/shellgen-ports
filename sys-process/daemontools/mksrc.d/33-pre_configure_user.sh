#!/bin/sh
# +static +static-libs -shared -upx +patch -doc -xstub +diet -musl +stest +strip +x32

inherit flag-o-matic toolchain-funcs

DESCRIPTION="Collection of tools for managing UNIX services"
HOMEPAGE="http://cr.yp.to/daemontools.html"
LICENSE="public-domain GPL-2"  # GPL-2 for init script
IUSE="-selinux +static"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

export AR="ar"

> home || die
