#!/bin/sh
# 2022
# Date: 2023-10-15 18:00 UTC - fix: near to compat-posix

{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

WORKDIR="${WORKDIR}/unix"

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

test -x './configure' || return

./configure ${MYCONF} || return

printf "Configure directory: ${PWD}/... ok\n"
