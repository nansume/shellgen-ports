#!/bin/sh
# Copyright (C) 2023-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-04 18:00 UTC - fix: near to compat-posix, no-posix: local VAR

local EXIT='exit'
local NET_USER="clearnet"
local RUN="pkg_fetch"

test "0${BUILD_CHROOT}" -ne '0' || return 0
test "X${USER}" != 'Xroot' && return

#[[ -s src_uri.lst ]] || return 0

>>"checksums".lst

mkdir -pm '0755' -- "${DISTSOURCE:?}/"
# Swith User Network - nopriv
test -d "${DISTSOURCE}" && chown ${NET_USER}:${NET_USER} "${DISTSOURCE}/"
test -d "${DISTDIR}"    && chown ${NET_USER}:${NET_USER} "${DISTDIR}/"
chown ${NET_USER}:${NET_USER} checksums.lst

#trap { set +o xtrace;} >/dev/null 2>&1; trap - RETURN' RETURN

RUN=$(type ${RUN})
RUN=${RUN##* }
USE_BUILD_ROOT='0'

test "x${RUN}" = 'xbuiltin' && return

#set -o xtrace
# ${PWD%/}/misc.d/pkg_fetch
# BASH_ENV=${BASH_ENV:?}
# 1=XPWD 2=BUILD_CHROOT 3=USE_BUILD_ROOT 4=PDIR 5=DISTSOURCE 6=DISTDIR 7=HOME 8=USER 9=LOGNAME 10=PWD
# 11=PV 12=PN 13=XPN 14=XPV 15=CATEGORY 16=GITCOMMIT 17=COMMIT
HOME=${PWD} su -p ${NET_USER:?} -s "${RUN}" \
 "${XPWD:?}" \
 "${BUILD_CHROOT:?}" \
 "${USE_BUILD_ROOT:?}" \
 "${PDIR:?}" \
 "${DISTSOURCE}" \
 "${DISTDIR:?}" \
 "${PWD}" \
 "${NET_USER}" \
 "${NET_USER}" \
 "${PWD}" \
 "${PV}" \
 "${PN}" \
 "${XPN}" \
 "${XPV}" \
 "${CATEGORY}" \
 "${GITHASH}" \
 "${HASH}" ||

{ { set +o xtrace;} >/dev/null 2>&1; ${EXIT};}

test -d "${DISTSOURCE}"  && chown -hR root:root "${DISTSOURCE}/"
test -d "${DISTDIR}"     && chown root:root "${DISTDIR}/"
test -e "checksums.lst"  && chown root:root "checksums.lst"
test -e "src_uri.lst"    && chown root:root "src_uri.lst"
