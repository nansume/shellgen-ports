#!/bin/sh
# Copyright (C) 2021-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-05 12:00 UTC - fix: near to compat-posix, no-posix: local VAR

local IFS="$(printf '\n\t')"; IFS=${IFS%?}; local PN=${XPN}; local GLOBIGNORE; local P

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${INSTALL_DIR}" || exit
cd "${INSTALL_DIR}/"

GLOBIGNORE="${GLOBIGNORE:+${GLOBIGNORE}:}$(excludelist)"  # glob ignore load
GLOBIGNORE=${GLOBIGNORE%:}

printf %s\\n "GLOBIGNORE='${GLOBIGNORE}'"

#shopt -s dotglob globstar
for P in '' ${RMLIST}; do
  test -z "${P}" && { RMLIST=; continue;}
  test -n "${GLOBIGNORE}" && { smatch-list "${P}" "${GLOBIGNORE}" && continue;}
  case ${P} in *'.a'|*'.la') { use 'static-libs' || use 'static-lib' ;} && continue;; esac
  test -e "${P}" && RMLIST="${RMLIST:+${RMLIST} }${P}"
done
test -n "${RMLIST}" || return 0
IFS=' '

#set -o xtrace
# fix bug: <rm> opts add <-f> null remove
rm -r -- ${RMLIST} &&  # rm: libx32/libblkid.la: No such file or directory - duplicate (same file)
printf %s\\n "rm -r -- ${RMLIST}"
{ set +o 'xtrace';} >/dev/null 2>&1
