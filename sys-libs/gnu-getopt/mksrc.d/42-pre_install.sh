#!/bin/sh

ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

test -d "${WORKDIR}" || return
cd "${WORKDIR}/"

MAKEFLAGS="prefix= libdir=/$(get_libdir)"

make ${MAKEFLAGS} DESTDIR=${ED} install || die "make install... error"
