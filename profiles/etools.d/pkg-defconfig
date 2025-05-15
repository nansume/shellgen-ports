#!/bin/sh
# Copyright (C) 2022-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-08 17:00 UTC - fix: near to compat-posix, no-posix: local VAR

local F

test -d "${WORKDIR}" || return 0
cd "${WORKDIR}/"

test "0${BUILD_CHROOT}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "0${USE_BUILD_ROOT}" -ne '0' ;} || return 0

trap "test -x '/opt/xbin/hush' && ln -sf hush /opt/xbin/sh && printf '%s\n' 'ln -sf hush -> /opt/xbin/sh'" 0

uname -sm

test -e '.config' && return

if test -f 'defconfig'; then
  cp -nl 'defconfig' .config
else
  test -x '/opt/xbin/bash' && ln -sf 'bash' /opt/xbin/sh && printf %s\\n 'ln -sf bash -> /opt/xbin/sh'
  for F in */* */*/* */*/*/*; do
    test -f "${F}" &&
    case ${F} in
      *'/'*'_defconfig'|*'/defconfig')
        make defconfig >> '/var/log/mkconfig.log' || exit
        break
      ;;
    esac
  done
  test -x '/opt/xbin/hush' && ln -sf 'hush' /opt/xbin/sh && printf %s\\n 'ln -sf hush -> /opt/xbin/sh'
fi
