#!/bin/sh
# Copyright (C) 2021-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-09 12:00 UTC - fix: near to compat-posix, no-posix: local VAR

local IFS="$(printf '\n\t')"; IFS=${IFS%?}; local DPREFIX=${DPREFIX#/}; local GLOBIGNORE; local F

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

# skip mod: lib*/grub/i386-pc/*.mod
# skip mod: lib*/grub/i386-pc/*.img
for F in $(dotglobstar 'bin/') $(dotglobstar 'lib/') $(dotglobstar "${LIB_DIR}/") $(dotglobstar 'sbin/'); do
  case ${F} in */*.ko|*/*.o|*/*.a|*/*.mod|*/*.img|*/libgcc_s.so.?) continue;; esac
  test -e "${F}" || continue
  testelf ${F} || continue
  test -x "${F}" && continue
  set -o 'xtrace'
  chmod +x "${F}"
  { set +o 'xtrace';} >/dev/null 2>&1
done

set -- "$(get_libdir)/pkgconfig/"*.pc "$(get_libdir)/pkgconfig/"*/*.pc
# freedroid fix: -x share/<PN>/graphics/*.ico
set -- ${*} ${DPREFIX}"/share/"*/* ${DPREFIX}"/share/"*/*/* ${DPREFIX}"/share/"*/*/*/*

set -- ${*} */*.a  #2025.04.17 - FIX: for pkg libx86

for F in ${*}; do
  case ${F} in
    *'.pc'|*/*'.png'|*/*'.ico'|*/*'.a')
      test -x "${F}" || continue
      set -o 'xtrace'
      chmod -x "${F}"
      { set +o 'xtrace';} >/dev/null 2>&1
    ;;
  esac
done
