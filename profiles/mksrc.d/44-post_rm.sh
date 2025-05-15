#!/bin/sh
# Copyright (C) 2021-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-09 16:00 UTC - fix: near to compat-posix, no-posix: local VAR

ED=${INSTALL_DIR}
unset GLOBIGNORE

local IFS="$(printf '\n\t')"; IFS=${IFS%?}; local INCDIR=${INCDIR#/}; local DPREFIX=${DPREFIX#/}
local F; local GLOBIGNORE

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd "${ED}/" || return

GLOBIGNORE="${GLOBIGNORE:+${GLOBIGNORE}:}$(excludelist)"  # glob ignore load
GLOBIGNORE=${GLOBIGNORE%:}

#set -o xtrace
for F in $(globstar "${LIB_DIR}/"); do
  test -n "${GLOBIGNORE}" && { smatch-list "${F}" "${GLOBIGNORE}" && continue;}
  case ${F} in *'.a'|*'.la') { use 'static-libs' || use 'static-lib' ;} && continue;; esac
  case ${F} in
    */*'.la'|*/*'.a'|*/*'.pyc'|*/*'.pyo'|*/*'.exe'|*/*'.bat')
      test -e "${F}" && rm -- "${F}" && printf %s\\n "rm -- ${F}"
    ;;
  esac
done

for F in $(globstar 'lib/'); do
  test -n "${GLOBIGNORE}" && { smatch-list "${F}" "${GLOBIGNORE}" && continue;}
  case ${F} in
    */*'.pyc'|*/*'.pyo'|*/*'.exe'|*/*'.bat')
      test -e "${F}" && rm -- "${F}" && printf %s\\n "rm -- ${F}"
    ;;
  esac
done
{ set +o 'xtrace';} >/dev/null 2>&1

if use !static-libs && use !shared; then
  for F in "$(get_libdir)/"*.so*; do
    break
  done
  if { test ! -x "${F}" && test -d "$(get_libdir)/" && test -d "${INCDIR}/" ;}; then
    rm -rf -- "${LIB_DIR:?}/" "${INCDIR:?}/"
    printf %s\\n "nolibs: rm -rf -- ${LIB_DIR}/ ${INCDIR}/"
  fi
fi

use 'man'      || { test -d "${DPREFIX}/share/man"             && rm -v -r -- "${DPREFIX}/share/man/" ;}
use 'doc'      || { test -d "${DPREFIX}/share/doc"             && rm -v -r -- "${DPREFIX}/share/doc/" ;}
use 'info'     || { test -d "${DPREFIX}/share/info"            && rm -v -r -- "${DPREFIX}/share/info/";}
use 'icon'     || { test -d "${DPREFIX}/share/icons"           && rm -v -r -- "${DPREFIX}/share/icons/";}
use 'icon'     || { test -d "${DPREFIX}/share/pixmaps"         && rm -v -r -- "${DPREFIX}/share/pixmaps/";}
use 'desktop'  || { test -d "${DPREFIX}/share/applications"    && rm -v -r -- "${DPREFIX}/share/applications/";}
use 'bashcomp' || { test -d "${DPREFIX}/share/bash-completion" && rm -v -r -- "${DPREFIX}/share/bash-completion/";}

use 'ltconf' || { test -d "$(get_libdir)" && { find "$(get_libdir)/" -name '*.la' -delete || die;} ;}
