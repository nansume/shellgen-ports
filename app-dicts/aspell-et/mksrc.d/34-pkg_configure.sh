#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -xstub -diet -musl +stest +strip +x32

DESCRIPTION="Aspell (Estonian) language dictionary"
HOMEPAGE="http://aspell.net/"
LICENSE="GPL-2"
PV=${PV#*[a-z]-}
NL="$(printf '\n\t')"; NL=${NL%?}
EPREFIX=${SPREFIX}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

local IFS="${NL} "

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

./configure \
  --vars DESTDIR="${ED}" \
  --vars datadir="${DPREFIX}/share/aspell" \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"
