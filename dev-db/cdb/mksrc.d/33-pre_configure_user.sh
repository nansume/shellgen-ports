#!/bin/sh
# +static +static-libs -shared -upx +patch -doc -xstub +diet -musl -stest +strip +x32

inherit toolchain-funcs

DESCRIPTION="Fast, reliable, simple package for creating and reading constant databases"
HOMEPAGE="http://cr.yp.to/cdb.html"
LICENSE="public-domain"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

export EPREFIX BUILD_DIR

local EPREFIX=${EPREFIX%/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

# busybox compat
sed -i -e "s/head -1/head -n 1/g" Makefile

printf '%s\n' "${CC} ${CFLAGS} -fPIC" > conf-cc || die
printf '%s\n' "${CC} ${LDFLAGS}" > conf-ld || die
printf '%s\n' "${EPREFIX}/usr" > conf-home || die
