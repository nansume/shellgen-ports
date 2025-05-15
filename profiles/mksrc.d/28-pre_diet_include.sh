#!/bin/sh

DIETHOME="/opt/diet"

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

if use 'diet'; then
  CC="${CC} -I."  # add headers from build dir
  #CC="${CC} -I${DIETHOME}/include"  # 2025.04.20 - FIX: it comment, replace by <-isystem>
  CC="${CC} -isystem ${DIETHOME}/include"  # 2025.04.20
  CC="${CC} -I/usr/include"
  [ -d "/usr/include/libowfat" ] && CC="${CC} -I/usr/include/libowfat"
fi