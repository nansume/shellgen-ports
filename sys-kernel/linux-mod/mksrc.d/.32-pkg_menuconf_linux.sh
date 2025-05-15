#!/bin/bash
# Copyright (C) 2021-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html


declare -gx KBUILD_BUILD_HOST='linux' KBUILD_VERBOSE='1'

[[ -d ${WORKDIR} ]] || return 0
cd ${WORKDIR}/


(( UID || "USE_BUILD_ROOT" )) || return 0

#if [[ ! -e .config ]]; then
#  read -resn 100 -p `copy: .config kernel!: ` \
#   -i /mnt/${DISK}/boot/linux_${ABI}_${DEVICE}_${DATE}.config local_FILE
#  [[ ${FILE:?} ]]
#
#  #cp -p ${FILE} .config
#  cp -nl ../../*.config .config
#fi

[[ -e 'vmlinuz' ]] || make oldconfig
make menuconfig

#((UID)) && exit
[[ -x "${PDIR}/bin/echo" ]] || return 0
ln -sf "${PDIR}/bin/echo" '/bin/'