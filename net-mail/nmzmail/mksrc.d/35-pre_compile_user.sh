#!/bin/sh
# +static -static-libs -shared +nopie -lfs -upx +patch -doc -xstub -diet +musl +stest +strip +x32

BUILD_DIR=${BUILD_DIR:-$WORKDIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

sed -e '/^LIBS =/ s/ -lreadline/ -lreadline -ltinfo/' -i Makefile src/Makefile
