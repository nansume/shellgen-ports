#!/bin/sh
# +static +static-libs -shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit autotools flag-o-matic install-functions

DESCRIPTION="Abook is a text-based addressbook program designed to use with mutt mail client"
HOMEPAGE="http://abook.sourceforge.net/"
LICENSE="GPL-2"
IUSE="-nls"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

local IFS="$(printf '\n\t') "

test "X${USER:?}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

autoreconf --install

MYCONF="${MYCONF}
 --enable-vformat
"

# bug #570428
append-cflags -std=gnu89

printf "Configure directory: ${PWD}/... ok\n"
