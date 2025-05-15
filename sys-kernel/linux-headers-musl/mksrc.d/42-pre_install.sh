#!/bin/sh

test "X${USER}" != 'Xroot' || return 0

test -d "${WORKDIR}" || return
cd "${WORKDIR}/"

case $(tc-chost) in
  *x32)     ARCH="x32"     ;;
  x86_64-*) ARCH="$(arch)" ;;
  i?86-*)   ARCH="i386"    ;;
esac

MAKEFLAGS="ARCH=${ARCH} prefix=/usr"

make V='0' DESTDIR='/install' ${MAKEFLAGS} install
