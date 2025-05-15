#!/bin/bash
# Copyright (C) 2021-2022 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html


((UID)) || return 0
cd ${INSTALL_DIR}/

mkdir -pm '0755' ${DPREFIX#/}/include/
shopt -so 'xtrace'
ln -s ${PN%w} ${DPREFIX#/}/include/${PN}
{ shopt -uo 'xtrace';} &>/dev/null