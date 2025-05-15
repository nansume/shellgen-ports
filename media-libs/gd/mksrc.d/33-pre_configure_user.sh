#!/bin/sh
# -static +static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Graphics library for fast image creation"
HOMEPAGE="https://libgd.org/ https://www.boutell.com/gd/"
LICENSE="gd IJG HPND BSD"
IUSE="-avif +cpu_flags_x86_sse +fontconfig +jpeg -heif +png"
IUSE="${IUSE} +static-libs -test +tiff +truetype +webp -xpm +zlib"
BUILD_DIR=${WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

# required testing
if use 'cpu_flags_x86_sse' ; then
  : append-cflags -msse -mfpmath=sse
else
  : append-cflags -ffloat-store
fi

autoreconf --install
