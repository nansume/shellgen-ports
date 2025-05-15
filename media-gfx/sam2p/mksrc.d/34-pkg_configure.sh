#!/bin/sh
# +static -static-libs -shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

export PN PV EPREFIX CC CXX

local IFS="$(printf '\n\t') "

DESCRIPTION="Utility to convert raster images to EPS, PDF and many others"
HOMEPAGE="https://github.com/pts/sam2p"
LICENSE="GPL-2"
IUSE="-examples +gif"
PV="0.49.4-p20190718"
EPREFIX=${SPREFIX}
BUILD_DIR=${WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

# missing include for memset
sed -i '1s;^;#include <string.h>\n;' pts_defl.c || die

./configure \
  --prefix="${EPREFIX%/}" \
  --bindir="${EPREFIX%/}/bin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --includedir="${INCDIR}" \
  --libexecdir="${DPREFIX}/libexec" \
  --datadir="${DPREFIX}/share" \
  --host=$(tc-chost) \
  --build=$(tc-chost) \
  --enable-lzw \
  $(use_enable 'gif') \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  $(use_enable 'nls') \
  $(use_enable 'rpath') \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"
