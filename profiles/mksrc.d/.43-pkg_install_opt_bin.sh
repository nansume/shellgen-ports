#!/bin/bash
# Copyright (C) 2022 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html


[[ -d ${WORKDIR} ]] || return 0
cd "${WORKDIR}/"

(( UID || "USE_BUILD_ROOT" )) || return 0

declare -I PN=${PN%-*} OLD_UMASK="$(umask -S)" OLDPWD
trap 'trap - RETURN; cd ${OLDPWD}; umask ${OLD_UMASK}' RETURN

umask u=rwx,g=rx,o=rx
mkdir -pm '0755' ${INSTALL_DIR}/opt/bin/

cp -nl "${INSTALL_DIR}/bin/${PN}" ${INSTALL_DIR}/opt/bin/

rm -- "${INSTALL_DIR}/bin/${PN}"