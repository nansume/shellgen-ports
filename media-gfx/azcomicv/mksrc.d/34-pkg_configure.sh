#!/bin/sh
# -static -static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="A simple comic viewer for Linux"
HOMEPAGE="http://azsky2.html.xdomain.jp/soft/azcomicv.html"
LICENSE="GPLv3"
IUSE="+tiff +webp -avif -psd"
NL="$(printf '\n\t')"; NL=${NL%?}
EPREFIX=${SPREFIX}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

local IFS="${NL} "

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

./configure \
  CC="${CC}" \
  --prefix="${EPREFIX%/}" \
  $(usex !tiff --without-tiff) \
  $(usex !webp --without-webp) \
  $(usex !avif --without-avif) \
  $(usex !psd --without-psd) \
  CFLAGS="${CFLAGS}" \
  LDFLAGS="-L/$(get_libdir)" \
  || die "configure... error"

cd build/

ninja

sed -e 's:^bindir=.*:bindir="${ED}/bin":' -i install.sh

ED=${ED} DESTDIR="${ED}/usr" bindir="${ED}/bin" ninja install

cd ../

printf "Configure directory: ${PWD}/... ok\n"
