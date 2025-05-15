#!/bin/sh

test "X${USER}" != 'Xroot' || return 0

test -d "${WORKDIR}" || return
cd "${WORKDIR}/"

MAKEFLAGS="prefix= libdir=/lib includedir=/usr/include"

make DESTDIR='/install' ${MAKEFLAGS} install
