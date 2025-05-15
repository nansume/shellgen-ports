# 2021-2023

local OPTS='shared'

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

test "0${BUILD_CHROOT}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "0${USE_BUILD_ROOT}" -ne '0' ;} || return 0

test "X${ABI}" = 'Xx32' && {
  OPTS="${OPTS:+${OPTS} }no-asm"
  #OPTS+=(no-md5)
  #OPTS+=(no-dh)
  #OPTS+=(no-bn)
}

# no-idea - nobuild
./config --prefix= --libdir="/${LIB_DIR}" ${OPTS}
