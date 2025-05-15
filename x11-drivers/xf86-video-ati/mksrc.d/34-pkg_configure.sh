#!/bin/sh
# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="ATI video driver"
HOMEPAGE="https://www.x.org/wiki/ati/"
LICENSE="MIT"
IUSE="-glamor -udev"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

./configure \
  CC="${CC}" \
  CXX="${CXX}" \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --sbindir="${EPREFIX%/}/sbin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --includedir="${INCDIR}" \
  --libexecdir="${DPREFIX}/libexec" \
  --datarootdir="${DPREFIX}/share" \
  --host=$(tc-chost) \
  --build=$(tc-chost) \
  --disable-udev \
  --disable-glamor \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  CFLAGS="${CFLAGS}" \
  CXXFLAGS="${CXXFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"
