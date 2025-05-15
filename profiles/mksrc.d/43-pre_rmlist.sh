#!/bin/sh
# Copyright (C) 2021-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-04 16:00 UTC - fix: near to compat-posix
# no-posix: ${X/a/b} ${X//a/b}

local IFS="$(printf '\n\t')"; IFS=${IFS%?}; local DPREFIX=${DPREFIX#/}; local F

test -d "${INSTALL_DIR}" || return 0
cd ${INSTALL_DIR}/

test "0${BUILD_CHROOT}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "0${USE_BUILD_ROOT}" -ne '0' ;} || return 0

#trap trap - RETURN; shopt -uo noglob' RETURN

RMLIST=
for X in "${PDIR%/}/lst.d/"[!.]*[_-]"rmlist_"*".lst"; do
  test -e "${X}" || continue
  #shopt -so noglob
  while IFS= read -r X; do
    test -n "${X%%#*}" || continue
    X=${X//<PN>/$XPN}
    X=${X/<PKGNAME>/$PKGNAME}
    X=${X/<DPREFIX>/$DPREFIX}
    X=${X/<LIB_DIR>/$LIB_DIR}
    RMLIST="${RMLIST:+${RMLIST}${IFS}}${X%%  \# *}"
  done < ${X}
done
