set -- 'shared'

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

printf %s\\n "./config --prefix=${SPREFIX%/}/ --libdir=/${LIB_DIR} ${@}"

./config --prefix="${SPREFIX%/}/" --libdir="/${LIB_DIR}" ${@}
