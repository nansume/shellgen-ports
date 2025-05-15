# 2021-2022

local DPREFIX=${DPREFIX#/}

test -d "${INSTALL_DIR}" || return 0
cd ${INSTALL_DIR}/

{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

umask u=rwx,g=rx,o=rx
set -o 'xtrace'
cp -ulr share/* ${DPREFIX}/share/
{ shet +o 'xtrace';} >/dev/null 2>&1

rm -r share/
