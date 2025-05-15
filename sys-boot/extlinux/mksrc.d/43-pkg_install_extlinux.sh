local DPREFIX=${DPREFIX#/}

test -d "${INSTALL_DIR}" || return 0
cd ${INSTALL_DIR}/

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

set -o 'xtrace'

test -d 'bin' && rmdir "bin/"
test -d "${DPREFIX}/bin" && mv -n ${DPREFIX}/bin .
test -d "${DPREFIX}/man" && rm -r -- ${DPREFIX}/man/

{ set +o 'xtrace';} >/dev/null 2>&1
