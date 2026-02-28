#!/bin/sh
# Copyright (C) 2023-2026 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2023-12-14 10:00 UTC, 2026-02-02 13:00 UTC - last change
# Usage [for bootstrap]: USE='+bootstrap +x32' emerge -b -- sys-libs/musl
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sys-libs/musl/musl-1.2.5-r3.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="Light, fast and simple C library focused on standards-conformance and safety"
HOMEPAGE="http://musl.libc.org"
LICENSE="MIT LGPL-2 GPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:=$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
PV="1.2.4"
PV="1.2.5"
SRC_URI="
  http://musl.libc.org/releases/${PN}-${PV}.tar.gz
  #http://musl.cc/x86_64-linux-muslx32-native.tgz
  https://www.openwall.com/lists/musl/2025/02/13/1/1 -> ${PN}-${PV}-fix-iconv-euc-kr.patch
  https://www.openwall.com/lists/musl/2025/02/13/1/2 -> ${PN}-${PV}-fix-iconv-input-utf8.patch
  http://data.gpo.zugaina.org/gentoo/sys-libs/musl/files/musl-sched.h-reduce-namespace-conflicts.patch
  http://localhost/pub/distfiles/patch/musl-1.2.5-read_timezone_from_fs.patch
  http://localhost/pub/distfiles/patch/musl-1.2.5-nftw-support-common-gnu-ext.patch
  http://data.gpo.zugaina.org/gentoo/sys-libs/musl/files/ldconfig.in-r3
  #http://data.gpo.zugaina.org/gentoo/sys-libs/musl/files/stack_chk_fail_local.c
  http://localhost/pub/distfiles/patch/musl-1.2.5-add-recallocarray-v4.diff
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-bootstrap +crypt -headers-only -split-usr"
IUSE="${IUSE} +static-libs +shared -doc (+musl) +stest +strip"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
P="${P:-${XPWD##*/}}"
SN=${P}
PORTS_DIR=${PWD%/$P}
DISTDIR="/usr/distfiles"
DISTSOURCE="${PDIR%/}/sources"
FILESDIR=${DISTSOURCE}
INSTALL_DIR="${PDIR%/}/install"
ED=${INSTALL_DIR}
SDIR="${PDIR%/}/${SRC_DIR}"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
PKGNAME=${PN}
ZCOMP="gunzip"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
IONICE_COMM='nice -n 19'

if test "X${USER}" != 'Xroot'; then
  mksrc-prepare
elif test "${BUILD_CHROOT:=0}" -eq '0'; then
  PATH="${PATH:+${PATH}:}${PDIR}/misc.d:${PDIR}/etools.d"
elif test "${BUILD_CHROOT:=0}" -ne '0'; then
  PATH="$(xpath):${PDIR%/}/misc.d:${PDIR%/}/etools.d"
  printf %s\\n "PATH='${PATH}'" "PDIR='${PDIR}'"
fi

. "${PDIR%/}/etools.d/"build-functions

chroot-build || die "Failed chroot... error"

use 'bootstrap' && tc-bootstrap-musl "$(arch)-linux-musl$(usex x32 x32 '')-native.tgz"

pkginst \
  "#dev-libs/mpfr" \
  "sys-devel/binutils6" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'bootstrap' ||
pkginst \
  "#sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "#sys-libs/musl"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"  # only for user-build

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-fix-iconv-euc-kr.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-fix-iconv-input-utf8.patch
  patch -p1 -E < "${FILESDIR}"/musl-sched.h-reduce-namespace-conflicts.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-read_timezone_from_fs.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-nftw-support-common-gnu-ext.patch
  #patch -p1 -E < "${FILESDIR}"/musl-1.2.5-add-recallocarray-v4.diff  # it exists in libbsd

  ./configure \
    CC="gcc" \
    CXX="g++" \
    AR="ar" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --syslibdir="${EPREFIX%/}/lib" \
    --enable-wrapper=$(usex 'glibc' gcc no) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" install || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  set -- "$(tc-abi)" 'lib'

  test -x 'bin/musl-gcc' && sed -e 's/-musl-gcc/-gcc/' -i bin/musl-gcc

  #ln -sf "../$(get_libdir)/libc.so" "${2}/ld-musl-${1}.so.1"
  #ln -sf 'libc.so' "$(get_libdir)/ld-musl-${1}.so.1" &&
  #printf %s\\n "ln -sf libc.so -> ${LIB_DIR}/ld-musl-${1}.so.1"

  mkdir -pm 0755 -- 'bin/'
  #ln -s "../$(get_libdir)/"ld-musl-*.so.1 'bin/ldd' &&
  ln -s "../$(get_libdir)/libc.so" 'bin/ldd' &&
  printf %s\\n "ln -s ../${LIB_DIR}/ld-musl-(get_libdir).so.1 -> bin/ldd"

  use 'strip' && pkg-strip
  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz