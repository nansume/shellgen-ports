#declare MAKEFLAGS=${MAKEFLAGS#* bin/}; MAKEFLAGS=${MAKEFLAGS%% *}

test -d "${INSTALL_DIR}" ]] || return 0
cd ${INSTALL_DIR}/

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

set -o 'xtrace'

cp -nl ${WORKDIR}/"bin/ipxe.lkrn" .

{ set +o 'xtrace';} >/dev/null 2>&1
