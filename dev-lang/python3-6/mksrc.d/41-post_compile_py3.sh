#!/bin/sh
# 2021-2023

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

mkdir -pm '0755' ${INSTALL_DIR}/".local"/

cd "${INSTALL_DIR}/.local/"

ln -sf ../bin ./
ln -sf ../lib ./
