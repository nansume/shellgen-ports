#!/bin/sh
# Copyright (C) 2021-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-07 16:00 UTC - fix: near to compat-posix, no-posix: local VAR

local NL="$(printf '\n\t')"; NL=${NL%?}; local IFS=${NL}
local XABI=${ABI}; local DBFILE="/var/db/pkgs.db"
local BUILD_CHROOT=${BUILD_CHROOT:-0}; local BUILDLIST=${BUILDLIST}
local DIRS; local PKGS; local MOUNTLIST; local DIR; local PKG; local XLIBABI; local STRING

{ test "X${USER}" != 'Xroot' || test "${BUILD_CHROOT:=0}" -ne '0' ;} && { USE_BUILD_ROOT='0'; return;}

BUILD_CHROOT='0'
DIRS="dev${NL}dev/shm${NL}pkg${NL}proc${NL}usr/distfiles"
PKGS="
 #sys-libs/glibc-compat
 #sys-libs/musl
 #app-busybox/ash
 #app-busybox/cat
 #app-busybox/hush
 #app-busybox/printf
 #app-shells/bash
 #dev-libs/gmp  #expr: error while loading shared libraries: libgmp.so.10
 #sys-apps/coreutils
 sys-apps/busybox
"

MOUNTLIST=
while IFS= read -r STRING; do
  MOUNTLIST="${MOUNTLIST:+${MOUNTLIST}${NL}}${STRING}"
done < '/proc/mounts'
MOUNTLIST="${MOUNTLIST:+${NL}${MOUNTLIST}${NL}}"

cpuonline '1'

#spkg-dep 'app-busybox/chroot' ||:

printf %s\\n "ABI_BUILD='${ABI_BUILD}'" "ABI='${ABI}'" "XABI='${XABI}'"
printf %s\\n "LIB_DIR='${LIB_DIR}'" "LIBDIR='${LIBDIR}'"

XLIBABI='lib'
case ${ABI_BUILD} in
  'x32')
    XLIBABI=${LIB_DIR}
  ;;
  'x86')
    XLIBABI='lib32'
    #[[ -e ${PDIR}/lib ]] || ln -sf ${XLIBABI} ${PDIR}/lib
    test -e "${PDIR}/${XLIBABI}" || ln -sf lib ${PDIR}/${XLIBABI}
  ;;
  'amd64')
    XLIBABI='lib64'
  ;;
esac
#chown ${BUILD_USER}:${BUILD_USER} ${PDIR}

for DIR in usr ${DIRS} bin etc lib ${XLIBABI} opt sbin var tmp var/log; do
  test -n "${DIR}" || continue
  test -d "${PDIR}/${DIR}" && continue
  test -L "${PDIR}/${DIR}" && continue
  mkdir -m '0755' ${PDIR}/${DIR}/
done
chmod 1777 ${PDIR}/tmp/
#mkdir -m 1777 ${PDIR}/tmp/  # 41777
test -e "${PDIR}/usr/bin"    || ln -sf ../bin    ${PDIR}/usr/bin
test -e "${PDIR}/usr/lib"    || ln -sf ../lib    ${PDIR}/usr/lib
test -e "${PDIR}/usr/${XLIBABI}" || ln -sf ../${XLIBABI} ${PDIR}/usr/${XLIBABI}
test -e "${PDIR}/usr/sbin"   || ln -sf ../sbin   ${PDIR}/usr/sbin

#set -o xtrace
printf %s "cp -urp /mnt/root/bin/ /mnt/root/etc/ /mnt/root/lib/ "
printf %s\\n "/mnt/root/opt/ /mnt/root/sbin/ /mnt/root/var/ ${PDIR}/"
cp -urp /mnt/root/bin/ /mnt/root/etc/ /mnt/root/lib/ /mnt/root/opt/ /mnt/root/sbin/ /mnt/root/var/ ${PDIR}/
{ set +o 'xtrace';} >/dev/null 2>&1

for DIR in ${DIRS}; do test -n "${DIR}" || continue
  case ${MOUNTLIST} in *" ${PDIR}/${DIR} "*) continue;; esac
  mount -nio 'bind' /${DIR}/ "${PDIR}/${DIR}/" &&
  printf '%s\n' "mount -nio bind /${DIR}/ ${PDIR}/${DIR}/"
done
test -x "${PDIR}/bin/gcc" || >"${PDIR}/${DBFILE:?}"  # pkg db file init for bootstrap

for PKG in ${PKGS}; do
  PKG=${PKG%%#*}
  PKG="${PKG#${PKG%%[![:space:]]*}}"
  test -n "${PKG}" || continue
  XABI=${ABI_BUILD}
  if ABI=${XABI} pkg-is ${PKG}; then
    :
  else
    XABI="x32"
  fi
  #ABI=${XABI} ROOT_DIR=${PDIR} spkg-dep ${PKG}
  ABI=${XABI} ROOT_DIR=${PDIR} spkg ${PKG}
done
XABI=${ABI}
#ABI=x32 ROOT_DIR=${PDIR} . spkg-dep glibc ncurses readline #bash
test -n "${BUILDLIST}" && BUILDLIST='1'

printf %s\\n "NSH='${NSH}'" "0='${0}'"

test -x 'bin/hush' && ln -sf 'hush' bin/sh && printf %s\\n 'ln -sf hush -> bin/sh'

printf %s "ABI=${ABI_BUILD} LIBDIR=/${XLIBABI} LIB_DIR=${XLIBABI} _ENV=${_ENV} USE_BUILD_ROOT=${USE_BUILD_ROOT}"
printf %s\\n " BUILD_CHROOT=1 XPWD=${PDIR} BUILDLIST=${BUILDLIST} chroot ${PDIR}/ /mksrc.sh"
#set -o xtrace
ABI=${ABI_BUILD} \
LIBDIR="/${XLIBABI}" \
LIB_DIR=${XLIBABI} \
_ENV=${_ENV} \
USE_BUILD_ROOT=${USE_BUILD_ROOT} \
BUILD_CHROOT='1' \
XPWD=${PDIR} \
BUILDLIST=${BUILDLIST} \
chroot ${PDIR}/ '/mksrc.sh'
{ set +o 'xtrace';} >/dev/null 2>&1

#ABI=${ABI_BUILD}  ROOT_DIR=${PDIR} . rmpkg ${PKGS[@]}

MOUNTLIST=
while IFS= read -r STRING; do
  MOUNTLIST="${MOUNTLIST:+${MOUNTLIST}${NL}}${STRING}"
done < '/proc/mounts'
MOUNTLIST="${MOUNTLIST:+${NL}${MOUNTLIST}${NL}}"

for DIR in '' ${DIRS}; do
  test -n "${DIR}" || { DIRS=; continue;}
  DIRS="${DIR}${DIRS:+${NL}${DIRS}}"
done

printf ''
for DIR in ${DIRS}; do
  sleep '1'
  test -n "${DIR}" &&
  case ${MOUNTLIST} in
    *" ${PDIR}/${DIR} "*) 'runverb' umount ${PDIR}/${DIR}/;;
  esac
done

USE_BUILD_ROOT='0'
