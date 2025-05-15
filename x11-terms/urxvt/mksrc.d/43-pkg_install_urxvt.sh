{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${INSTALL_DIR}" || exit
cd ${INSTALL_DIR}/

set -o 'xtrace'

test -d 'lib' && rmdir 'lib/'
mv -n ${LIB_DIR} 'lib'

{ set +o 'xtrace';} >/dev/null 2>&1
printf %s\\n 'Install... ok'
