test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

{ test -f 'Makefile' || test -f 'GNUmakefile' || test -f 'makefile' ;} || return 0

MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }PREFIX=${SPREFIX%/}/${INSTALL_DIR#/}"
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }prefix=${SPREFIX%/}/${INSTALL_DIR#/}"
