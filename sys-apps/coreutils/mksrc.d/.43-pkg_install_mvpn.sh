#!/bin/bash
# Copyright (C) 2022 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html


[[ -d ${WORKDIR} ]] || return 0
cd "${WORKDIR}/"

(( UID || "USE_BUILD_ROOT" )) || return 0

declare -I PN=${PN%-*} OLDPWD OLDPN
trap 'trap - RETURN; cd ${OLDPWD}' RETURN

cd "${INSTALL_DIR}/bin/"

OLDPN=*

cp -nl "${OLDPN}" ${PN}

rm -- "${OLDPN}"