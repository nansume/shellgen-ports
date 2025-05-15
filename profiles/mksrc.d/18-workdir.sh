#!/bin/sh

#WORKDIR=/usr/ports/${P}/${SRC_DIR}/${PKGNAME}-src
WORKDIR="${PDIR%/}/${SRC_DIR}/${PKGNAME}-src"
#WORKDIR=${PDIR%/}/${SRC_DIR}

printf %s\\n "SRC_DIR=${SRC_DIR} PKGNAME=${PKGNAME} builddir ${WORKDIR-}"
#SRC_DIR=${SRC_DIR} PKGNAME=${PKGNAME} builddir ${WORKDIR-}
WORKDIR="$(SRC_DIR=${SRC_DIR} PKGNAME=${PKGNAME} builddir ${WORKDIR-} 2>&1 || true)"

printf %s\\n "WORKDIR='${WORKDIR}'"


test "X${USER}" != 'Xroot' || return 0

test -n "${WORKDIR}" || exit

return 0  # it now no required, fix make in <19-sw_user.sh>.

{ test -z "${HOME}" || test "X${HOME}" = 'X/root' ;} || return 0

HOME="${PDIR%/}/${SRC_DIR}"
