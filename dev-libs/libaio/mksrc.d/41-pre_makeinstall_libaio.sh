{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS}${NL}}prefix=${SPREFIX}"
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS}${NL}}libdir=${SPREFIX%/}/${LIB_DIR}"
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS}${NL}}includedir=${INCDIR}"
