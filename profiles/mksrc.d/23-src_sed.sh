#!/bin/sh
# Copyright (C) 2021-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-08 13:00 UTC - fix: near to compat-posix, no-posix: local VAR

local PDIR=${PDIR}
local SED='sed'
local S; local F

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

export BUILD_DIR="$(SRC_DIR=${SRC_DIR} PKGNAME=${PKGNAME} builddir ${WORKDIR-} || true)"

PDIR=${PDIR%/}

{ test -x "/bin/g${SED}" && test ! -L "/bin/g${SED}" ;} && SED="/bin/g${SED}"
printf %s\\n "SED='${SED}'"

cd "${BUILD_DIR}/" || return

for S in "${DISTSOURCE}/"*'.sed' "${PDIR}/patches/"*'.sed'; do
  test -f "${S}" || continue
  test "X${ABI}" != 'Xx32' && case ${S} in *"${ABI}.sed") continue;; esac
  set -- '0'
  while IFS= read -r F; do
    set -- $(expr ${1} + '1')
    test "${1}" -ge '2' && break
  done < ${S}

  F=${F#*^}
  printf %s "${SED} -f ${S} -i ${F}"
  ${SED} -f "${S}" -i "${F}" && printf %s\\n "... ok" || printf %s\\n "... error"
done
