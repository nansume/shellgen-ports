#!/bin/sh
# 2021-2022
# Date: 2023-10-15 12:00 UTC - fix: near to compat-posix

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/misc/

{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

make ${MAKEFLAGS} DESTDIR="${INSTALL_DIR}" install
