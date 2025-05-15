#!/bin/sh

WORKDIR="${WORKDIR:-${PDIR%/}/${SRC_DIR}/${PKGNAME}-src}"

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${WORKDIR}" || return
cd ${WORKDIR}/

WORKDIR="$(SRC_DIR=${SRC_DIR} PKGNAME=${PKGNAME} builddir ${WORKDIR-} || true)"

printf %s\\n "WORKDIR='${WORKDIR}'"
