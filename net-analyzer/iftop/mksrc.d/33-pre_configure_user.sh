#!/bin/sh
# +static -static-libs -shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Display bandwidth usage on an interface"
HOMEPAGE="http://www.ex-parrot.com/pdw/iftop/ https://code.blinkace.com/pdw/iftop"
LICENSE="GPL-2"
BUILD_DIR=${WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

eautoreconf
