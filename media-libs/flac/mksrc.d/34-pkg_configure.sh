#!/bin/sh
# -static +static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

export PN PV EPREFIX CC CXX CBUILD CHOST

DESCRIPTION="Free lossless audio encoder and decoder"
HOMEPAGE="https://xiph.org/flac/"
LICENSE="BSD FDL-1.2 GPL-2 LGPL-2.1"
IUSE="+cxx -debug +ogg -cpu_flags_x86_avx2 -cpu_flags_x86_avx +static-libs"
IFS="$(printf '\n\t') "
EPREFIX=${SPREFIX}
BUILD_DIR=${WORKDIR}
CBUILD=$(tc-chost)
CHOST=$(tc-chost)

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

econf \
  --bindir="${EPREFIX%/}/bin" \
  --includedir="${INCDIR}" \
  --datarootdir="${DPREFIX}/share" \
  --disable-doxygen-docs \
  --disable-examples \
  $(use_enable 'cpu_flags_x86_avx' avx) \
  $(use_enable 'debug') \
  $(use_enable 'ogg') \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  $(use_enable 'rpath') \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"
