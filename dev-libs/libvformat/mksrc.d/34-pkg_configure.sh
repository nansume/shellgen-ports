#!/bin/sh
# -static +static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit autotools install-functions

DESCRIPTION="Library to read and write vcard files"
HOMEPAGE="https://sourceforge.net/projects/vformat/"
LICENSE="LGPL-2.1"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${SPREFIX%/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

autoreconf --install

./configure \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --sbindir="${EPREFIX%/}/sbin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --includedir="${INCDIR}" \
  --libexecdir="${DPREFIX}/libexec" \
  --datadir="${DPREFIX}/share" \
  --host=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
  --build=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  $(use_enable 'nls') \
  $(use_enable 'rpath') \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"
