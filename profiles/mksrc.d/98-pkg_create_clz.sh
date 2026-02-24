#!/bin/sh
# Copyright (C) 2021-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-03-26 16:00 UTC - last change
# Date: 2024-10-09 17:00 UTC - last change

local IFS="$(printf '\n\t')"; IFS="${IFS%?} "
local XABI=${INST_ABI}; local XDIR; local COLNORM; local COLRED; local ITEM; local XITEM; local PKGS

ED=${INSTALL_DIR}
#PKG_DIR='../../../../../pkg
PKG_DIR=${PKG_DIR:-/pkg}
#PKGS=app-busybox/find
XDIR="/mnt/zram/overlayfs/up/usr/ports/${CATEGORY}/${PN}"
COLNORM=$(printf '\e[m')
COLRED=$(printf '\e[0;31m')

{ test "X${USER}" != 'Xroot' || test "0${BUILD_CHROOT}" -ne '0' ;} && return

test -d "${ED}" || exit

printf %s\\n "PKG_DIR='${PKG_DIR}'"
if test -n "${BUILDLIST}"; then
  return
else
  cd "${ED}/"
fi
: ${XABI:?}

case ${XABI} in
  'all')
    test -d "${ED}/$(get_libdir)" &&
    { test -d "${ED}/lib" || { printf %s\\n "dir in pkg no compliance for <noarch>... Error"; exit 1;}; }
    # there in configure where check CC be die or is.
    test -x "${PDIR}/bin/cc" && use !noarch &&
      { printf %s\\n "compiler is no compliance for <noarch>... Error"; exit 1;}
  ;;
esac

use 'cxz' && PKGS="${PKGS:+${PKGS} }app-arch/xz"
#use clz && PKGS=${PKGS:+${PKGS} }app-busybox/lzop"


test -n "${PKGS}" && ABI=${ABI_BUILD} spkg-dep ${PKGS} ||:

# create package
test -d "${PKG_DIR}" || mkdir -m 0755 "${PKG_DIR}/"
test -d "${PKG_DIR}/${CATEGORY}" || mkdir -m 0755 "${PKG_DIR}/${CATEGORY}/"
#shopt -s globstar dotglob  # no compat posix

{ ! emptydir ${PWD} ;} &&
{
if use 'cxz' && ZCOMP='cxz'; then
  dotglobstar \
   | cpio -H newc -o \
   | xz --best --extreme --check=crc32 --lzma2=dict=1024KiB \
   > ../../../../../pkg/${CATEGORY}/${PN}_${PV}_${XABI}.cxz
elif use 'clz' && ZCOMP='clz'; then
  find . \
   | cpio -H newc -o \
   | lzop -6 -c \
   > ${PKG_DIR}/${CATEGORY}/${PN}_${PV}_${XABI}.clz
elif use 'cgz' && ZCOMP='cgz'; then
  dotglobstar \
   | cpio -H newc -o \
   | gzip -4 -c \
   > ${PKG_DIR}/${CATEGORY}/${PN}_${PV}_${XABI}.cgz
fi
} && printf '%s \e[0;31m%s\e[m\n' "create:" "${CATEGORY}/${PN}_${PV}_${XABI}.${ZCOMP}" ||:

cpuonline '0'

####  clean build dir, etc  ####
cd /

#: ${XITEM:=Y}
#printf "no-clean(${COLRED}Y${COLNORM}/${COLRED}n${COLNORM})[${COLRED}${XITEM}${COLNORM}]: "
#ITEM=$(timeout -s SIGINT '6' sh -c 'read -rn 1 I; printf %s "${I}"') ||:
#test -n "${ITEM}" || printf '%s\e[m\n' "${ITEM:=${XITEM}}"
#
#test "x${ITEM}" != 'xY' ||
#{
#if test -d "${XDIR:?}" && ! emptydir "${XDIR}"; then
#  rm -r -- "${XDIR}/"*
#  mount -nio 'remount,ro' / >/dev/null 2>&1
#  mount -nio 'remount,ro' /mnt/root/
#fi
#}
