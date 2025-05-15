#!/bin/sh

BUILD_DIR=${BUILD_DIR:-$WORKDIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

sed -e '/^LIBS = / s/ -lutil/ -lexpat -lutil/' -i src/Makefile

sed -e "s/terminfo//" -i Makefile || die "Can't remove terminfo"