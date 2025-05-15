#!/bin/sh
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-15 12:00 UTC - Log: fix near to compat-posix

local EXIT="exit" DPREFIX=${DPREFIX#/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${INSTALL_DIR}" || ${EXIT}
cd ${INSTALL_DIR}/

test -e "${DISTDIR}/${PN}-unihan-${PV}.zip" || ${EXIT}

set -o 'xtrace'

mkdir -pm '0755' ${DPREFIX}/share/${PN}/
for P in ${WORKDIR}/*; do
  test -e "${P}" || ${EXIT} && cp -ulr "${P}" "${DPREFIX}/share/${PN}/"
done

cp -n ${DISTDIR}/${PN}-unihan-${PV}.zip "${DPREFIX}/share/${PN}/"Unihan.zip

{ set +o 'xtrace';} >/dev/null 2>&1

printf %s\\n "Install... ok"
