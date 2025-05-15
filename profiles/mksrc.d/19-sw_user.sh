#!/bin/sh
# Copyright (C) 2021-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-07 18:00 UTC - fix: near to compat-posix, no-posix: local VAR

local EXIT='exit'; local LOGFILE=${LOGFILE}; local BUILDLIST=${BUILDLIST}; local F

test "0${BUILD_CHROOT}" -ne '0' || return 0
test "X${USER}" != 'Xroot' && { USE_BUILD_ROOT='0'; return;}

test -d "${PDIR:?}" || ${EXIT}
cd "${PDIR%/}/"

LOGFILE='/var/log/mkconfig.log'

: ${SRC_DIR:?} ${INSTALL_DIR:?}

test -f "${LOGFILE:?}" || > ${LOGFILE:?}
chown ${BUILD_USER}:${BUILD_USER} "${LOGFILE}"

>>'checksums'.lst
>>'src_uri'.lst

mkdir -pm '0755' -- "${SRC_DIR}/" "${INSTALL_DIR}/" "${DISTSOURCE:?}/"
# Swith User - nopriv
test -d "${SRC_DIR}"     && chown -R ${BUILD_USER}:${BUILD_USER} "${SRC_DIR}/"
test -d "${INSTALL_DIR}" && chown -hR ${BUILD_USER}:${BUILD_USER} "${INSTALL_DIR}/"
test -d "${DISTSOURCE}"  && chown ${BUILD_USER}:${BUILD_USER} "${DISTSOURCE}/"  # future - remove
test -s "checksums.lst" ||
{
  #[[ -d "${DISTSOURCE}/" ]] && chown ${BUILD_USER}:${BUILD_USER} "${DISTSOURCE}/"
  chown ${BUILD_USER}:${BUILD_USER} checksums.lst
}

#trap '{ set +o xtrace;} >/dev/null 2>&1; trap - RETURN RETURN

USE_BUILD_ROOT='0'

test -n "${BUILDLIST}" && BUILDLIST='1'
test -e '/etc/profile' && rm -- '/etc/profile'
printf %s\\n "PWD='${PWD}'"

test -L '/bin/bash' || {
  mkdir -pm '0755' /opt/xbin/
  cp -nl /bin/'sh' /bin/'ash' /bin/'bash' /bin/'hush' /opt/xbin/
  chown ${BUILD_USER}:${BUILD_USER} '/opt/xbin/' '/opt/xbin/'* &&
  printf %s\\n "chown ${BUILD_USER}:${BUILD_USER} /opt/xbin/ /opt/xbin/*"
  test -x '/opt/xbin/sh' && ln -sf '/opt/xbin/sh' /bin/sh && printf %s\\n 'ln -sf /opt/xbin/sh -> /bin/sh'
}

# 1=ABI_BUILD 2=LIBDIR 3=LIB_DIR 4=PDIR 5=XPWD 6=XPN 7=BUILD_CHROOT
#  8=_BASH_ENV 9=USE_BUILD_ROOT 10=BUILDLIST 11=CATEGORY 12=PN
#su -l ${BUILD_USER} -s ${PWD%/}/${BASH_SOURCE[2]##*/}" \
# is required fix when be change <workdir>: HOME=${PDIR%/}/${SRC_DIR} -> HOME=${WORKDIR}
USER=${BUILD_USER} \
HOME="${PDIR%/}/${SRC_DIR}" \
_UID="$(finduserid ${BUILD_USER})" \
su -p ${BUILD_USER} -s "${PWD%/}/mksrc.sh" \
  "${ABI_BUILD:?}" \
  "${LIBDIR:?}" \
  "${LIB_DIR:?}" \
  "${PDIR:?}" \
  "${XPWD:?}" \
  "${XPN:?}" \
  "${BUILD_CHROOT:?}" \
  "${_ENV}" \
  "${USE_BUILD_ROOT:?}" \
  "${BUILDLIST}" \
  "${CATEGORY:?}" \
  "${PN:?}" &&

{ set +o 'xtrace';} >/dev/null 2>&1 ||

{ { set +o 'xtrace';} >/dev/null 2>&1; return 1;}
