#!/bin/sh

test -d "${WORKDIR}" || return
cd "${WORKDIR}/"

test "X${USER}" != 'Xroot' || return 0

MAKEFLAGS="prefix=/ libdir=/${LIB_DIR} includedir=/usr/include datarootdir=/usr/share"

make DESTDIR='/install' ${MAKEFLAGS} install
