#!/bin/sh
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-07 18:00 UTC - fix: near to compat-posix, no-posix: local VAR

local X="/${LIB_DIR}/cmake"

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -x "${X}" && export CMAKE_PREFIX_PATH=${X}
test -n "${CMAKE_PREFIX_PATH-}" || return 0

printf %s\\n "BUILD_CHROOT='${BUILD_CHROOT}'" "USER='${USER}'" "USE_BUILD_ROOT='${USE_BUILD_ROOT}'"
printf %s\\n "CMAKE_PREFIX_PATH='${CMAKE_PREFIX_PATH}'"
