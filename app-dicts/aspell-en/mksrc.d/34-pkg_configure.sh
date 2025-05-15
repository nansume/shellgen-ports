#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -xstub -diet -musl +stest +strip +x32

DESCRIPTION="Aspell (English (British, Canadian, US)) language dictionary"
HOMEPAGE="http://aspell.net/"
LICENSE="Ispell myspell-en_CA-KevinAtkinson Princeton public-domain"
#PN="aspell-en"
PV=${PV#*[a-z]-}
NL="$(printf '\n\t')"; NL=${NL%?}
EPREFIX=${SPREFIX}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

local IFS="${NL} "

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

#--vars dictdir=${ED} \

./configure \
  --vars DESTDIR="${ED}" \
  --vars datadir="${DPREFIX}/share/aspell" \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"
