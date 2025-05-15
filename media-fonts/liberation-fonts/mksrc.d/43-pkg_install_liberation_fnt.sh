# 2021-2023

local DPREFIX=${DPREFIX#/}

test -d "${INSTALL_DIR}" || return 0
cd ${INSTALL_DIR}/

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${DPREFIX}/share/fonts" || return

set -o 'xtrace'
mkdir -m 0755 "${DPREFIX}/share/fonts/${PN}/"
cp -nl ${DPREFIX}/share/fonts/${PN}-*/* "${DPREFIX}/share/fonts/${PN}/"
rm -- "${DPREFIX}/share/fonts/${PN}"-*/*
chmod -x ${DPREFIX}/share/fonts/${PN}/*".ttf"
{ set +o 'xtrace';} >/dev/null 2>&1
