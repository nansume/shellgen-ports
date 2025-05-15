#!/bin/bash
# Copyright (C) 2021-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html


((BUILD_CHROOT)) || return 0
((UID)) && return
#[[ -d ${INSTALL_DIR}/ ]] || return

#cd ${INSTALL_DIR}/

chown root:root "${DPREFIX}/include/"