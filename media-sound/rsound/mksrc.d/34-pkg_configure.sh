#!/bin/sh
# -static +static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32
# same to support: +static +static-libs +shared

local IFS="$(printf '\n\t') "

DESCRIPTION="Networked audio system to transfer audio data to a different computer."
HOMEPAGE="https://github.com/Themaister/RSound/"
LICENSE="GPL-3"
IUSE="+alsa -alsamod -ao -jack +libsamplerate -openal -oss -portaudio -pulseaudio -vlcmod"
EPREFIX=${SPREFIX}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

unset MAKEFLAGS

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

use 'static' && CC="gcc --static"

CFLAGS=${CFLAGS/-no-pie }

./configure \
  --prefix="${EPREFIX%/}" \
  --disable-muroar \
  --disable-roar \
  --enable-syslog \
  $(use_enable 'alsa') \
  $(use_enable 'ao' libao) \
  $(use_enable 'jack') \
  $(use_enable 'openal') \
  $(use_enable 'oss') \
  $(use_enable 'portaudio') \
  $(use_enable 'pulseaudio' pulse) \
  $(use_enable 'libsamplerate' samplerate) \
  || die "configure failed"

printf "Configure directory: ${PWD}/... ok\n"

mkdir -pm '0755' ${ED}/lib64/pkgconfig/ ${ED}/include/ ${ED}/share/man/man1/

make -j"$(nproc)" V='0' \
  DESTDIR=${ED} \
  PREFIX='' \
  LDFLAGS="${LDFLAGS}" \
  all install \
  || die "Failed make build"

use 'x32' && mv -n ${ED}/lib64 ${ED}/libx32

rm -- Makefile
