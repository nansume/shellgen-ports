#!/bin/sh
# 2023-2024
# Date: 2024-03-29 12:00 UTC - last change

local DPREFIX=${DPREFIX#/}
local PKG_CONFIG_LIBDIR=${PKG_CONFIG_LIBDIR#/}
local PKG_CONFIG

test -d "${INSTALL_DIR}" || return 0
cd ${INSTALL_DIR}/

test "0${BUILD_CHROOT}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "0${USE_BUILD_ROOT}" -ne '0' ;} || return 0

{ test -d "include" && test -d "${DPREFIX}" ;} && mv -n include/ ${DPREFIX}/

test -d "etc/ssl/man" && rm -r -- "etc/ssl/man/"

for PKG_CONFIG in ${PKG_CONFIG_LIBDIR}/*".pc"; do
  test -e "${PKG_CONFIG}" &&
  sed -i \
    -e "/^prefix=/s|=.*$|=/${DPREFIX}|" \
    -e "/^exec_prefix=/s|=.*$|=|" \
    -e "/^libdir=/s|//|/|" \
    ${PKG_CONFIG}
done
