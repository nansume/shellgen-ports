#!/bin/bash
# Copyright (C) 2021-2022 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html


((UID||BUILD_CHROOT)) && return
declare IFS=$'\n' XABI=${ABI} BDEV='root' MOUNTLIST=('') XBDEV MESG N

MESG=$'[\e[31msda\e[m|\e[31msdb3\e[m|\e[31mroot\e[m] \e[32mBDEV=\e[1;34m'
XBDEV="/dev/${BDEV}"; N=${#XBDEV}

trap '
  trap - RETURN; { shopt -uo "xtrace";} &>/dev/null
  [[ ${MOUNTLIST[@]} == *" /dev/${BDEV} /mnt/${BDEV} "* ]] &&
  mount -nio "remount,ro" /mnt/${BDEV}/
' RETURN

[[ -d ${INSTALL_DIR}/ ]] || return
cd "${INSTALL_DIR}/"

[[ -e /mnt/${BDEV}/pkg/${PN}_${PV}_${XABI}.cxz ]] || return

read -ren ${N} -t ${N} -p "${MESG}" -i "${XBDEV}" -d "${IFS}" BDEV &&
{
  printf '\e[m'; BDEV=${BDEV#/dev/}
} ||

{ : "${BDEV:=${XBDEV#/dev/}}"; printf '\e[m\n';}

[[ ${BDEV-} ]] || return
declare -p BDEV
mapfile -tn '50' -O '1' -d "${IFS}" MOUNTLIST < '/proc/mounts'

[[ ${MOUNTLIST[@]} != *" /mnt/${BDEV}/boot "* ]] || return
[[ ${MOUNTLIST[@]} == *" /dev/${BDEV} /mnt/${BDEV} "* ]] || return
[[ -e "/mnt/${BDEV}/pkg/${PN}_${PV}_${XABI}.cxz" ]] && return

mount -nio 'remount,rw' /mnt/${BDEV}/
shopt -so 'xtrace'

cp -np ../../pkg/${PN}_${PV}_${XABI}.cxz /mnt/${BDEV}/pkg/