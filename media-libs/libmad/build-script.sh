#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2024-11-15 17:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/media-libs/libmad/libmad-0.15.1b-r10.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="\"M\"peg \"A\"udio \"D\"ecoder library"
HOMEPAGE="https://mad.sourceforge.net"
LICENSE="GPL-2+"
DOCS="CHANGES CREDITS README TODO VERSION"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="0.15.1b"
URI_BASE="http://data.gpo.zugaina.org/gentoo/media-libs/libmad"
SRC_URI="
  https://downloads.sourceforge.net/mad/${PN}-${PV}.tar.gz
  ${URI_BASE}/files/${PN}-${PV}-cflags.patch
  ${URI_BASE}/files/${PN}-${PV}-cflags-O2.patch
  ${URI_BASE}/files/${PN}-${PV}-gcc44-mips-h-constraint-removal.patch
  ${URI_BASE}/files/${PN}-${PV}-CVE-2017-8372_CVE-2017-8373_CVE-2017-8374.patch
  http://data.gpo.zugaina.org/gentoo/media-libs/libmad/files/mad.pc
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-debug -static-libs +shared -doc (+musl) +stest +strip"
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

pkginst \
  "dev-lang/perl  # required for autotools" \
  "sys-apps/file" \
  "sys-devel/autoconf  # required for autotools" \
  "sys-devel/automake  # required for autotools" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/libtool  # required for autotools,libtoolize" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

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

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-cflags.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-cflags-O2.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-gcc44-mips-h-constraint-removal.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-CVE-2017-8372_CVE-2017-8373_CVE-2017-8374.patch

  # bug 467002
  sed -e 's/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/' -i configure.ac || die

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --enable-speed \
    --enable-fpm=$(usex 'x86' intel 64bit) \
    $(use_enable 'debug' debugging) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  # This file must be updated with each version update
  mkdir -m 0755 -- "$(get_libdir)/pkgconfig/"
  cp -n "${FILESDIR}"/mad.pc -t "$(get_libdir)/pkgconfig/"

  sed -e "s/%VERSION%/${PV}/g" -i $(get_libdir)/pkgconfig/mad.pc
  # Use correct libdir in pkgconfig file
  sed -e "s|^libdir=.*|libdir=/$(get_libdir)|" -i $(get_libdir)/pkgconfig/mad.pc

  : einstalldocs
  find "$(get_libdir)/" -name '*.la' -delete || die

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
