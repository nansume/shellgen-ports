#!/bin/sh
# +static -static-libs -shared +nopie -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="this is hexedit0r, rofl0r's fork of hexedit 1.2.12"
HOMEPAGE="<url>"
LICENSE="GPL-2"
IUSE="+static -doc (+musl) +stest +strip"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

export PN PV BUILD_DIR

local IFS="$(printf '\n\t')"

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

sed -e '/$(LDFLAGS)/ s:-lncurses:-lncurses -ltinfo:' -i Makefile
