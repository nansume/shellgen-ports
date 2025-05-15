#!/bin/bash
# Copyright (C) 2021-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html


declare EXIT='exit'

((UID||BUILD_CHROOT)) && return

[[ -d ${INSTALL_DIR} ]] || ${EXIT}
cd ${INSTALL_DIR}/

chown -R :httpd "etc/sv.conf/"*".env" "lib/shell/"*"/" "sbin/rc.d/"*".sh"
chown -R httpd:httpd "home/httpd/"