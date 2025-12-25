#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-12-20 09:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-libs/mbedtls/mbedtls-3.6.4.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="Cryptographic library for embedded systems"
HOMEPAGE="https://tls.mbed.org/"
LICENSE="Apache-2.0"  # compatible with GPLv2+, GPLv3
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
PV="3.6.5"
BASE_URI="http://data.gpo.zugaina.org/gentoo/net-libs/mbedtls/files"
SRC_URI="
  https://github.com/Mbed-TLS/mbedtls/releases/download/${PN}-${PV}/${PN}-${PV}.tar.bz2
  ${BASE_URI}/mbedtls-3.6.2-allow-install-headers-to-different-location.patch
  ${BASE_URI}/mbedtls-3.6.4-add-version-suffix-for-all-installable-targets.patch
  ${BASE_URI}/mbedtls-3.6.2-add-version-suffix-for-pkg-config-files.patch
  ${BASE_URI}/mbedtls-3.6.2-exclude-static-3dparty.patch
  ${BASE_URI}/mbedtls-3.6.4-slotted-version.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
inst="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+cpu_flags_x86_sse2 -programs -test +threads -perl -python3 -minimal"
IUSE="${IUSE} +static +static-libs +shared -doc (-diet) (+musl) +stest +strip"
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
ZCOMP="bunzip2"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
CMAKE_PREFIX_PATH="/${LIB_DIR}/cmake"
PROG=${PN}

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
  "dev-build/cmake3  # cmake4" \
  "dev-util/pkgconf  # deps cmake" \
  "sys-devel/binutils6  # binutils6" \
  "sys-devel/gcc6  # gcc6" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  || die "Failed install build pkg depend... error"

if use 'diet'; then
  pkginst "dev-libs/dietlibc0"
else
  pkginst \
    "sys-libs/musl" \
    "sys-kernel/linux-headers-musl" \
    || die "Failed install build pkg depend... error"
fi

use 'perl' && pkginst "dev-lang/perl"
use 'python3' && pkginst "dev-lang/python3-12"

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
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -Os
  append-ldflags -Wl,--gc-sections
  #use 'static' && append-ldflags "-s -static --static"
  append-cflags -ffunction-sections -fdata-sections
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && inst="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  gpatch -p1 -E < "${FILESDIR}/mbedtls-3.6.2-allow-install-headers-to-different-location.patch"
  gpatch -p1 -E < "${FILESDIR}/mbedtls-3.6.4-add-version-suffix-for-all-installable-targets.patch"
  gpatch -p1 -E < "${FILESDIR}/mbedtls-3.6.2-add-version-suffix-for-pkg-config-files.patch"
  gpatch -p1 -E < "${FILESDIR}/mbedtls-3.6.2-exclude-static-3dparty.patch"
  gpatch -p1 -E < "${FILESDIR}/mbedtls-3.6.4-slotted-version.patch"

  use 'cpu_flags_x86_sse2' &&
  sed -e "s://\(#define MBEDTLS_HAVE_SSE2\):\1:" -i include/${PN}/${PN}_config.h
  use 'threads' &&
  sed \
    -e "s://\(#define MBEDTLS_THREADING_C\):\1:" \
    -e "s://\(#define MBEDTLS_THREADING_PTHREAD\):\1:" \
    -i include/${PN}/${PN}_config.h

  sed -e "s:VERSION 3.5.1:VERSION 3.10:g" -i CMakeLists.txt || die

  cmake -B build -G "Unix Makefiles" \
    -D CMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -D CMAKE_INSTALL_BINDIR="bin" \
    -D CMAKE_INSTALL_LIBDIR="$(get_libdir)" \
    -D CMAKE_INSTALL_INCLUDEDIR="usr/include/mbedtls3" \
    -D CMAKE_INSTALL_DATAROOTDIR="${DPREFIX#/}/share" \
    -D CMAKE_INSTALL_DOCDIR="${DPREFIX#/}/share/doc" \
    -D CMAKE_BUILD_TYPE="MinSizeRel" \
    -D ENABLE_PROGRAMS=$(usex 'programs' ON OFF) \
    -D ENABLE_SLOTTED_VERSION=ON \
    -D INSTALL_MBEDTLS_HEADERS=ON \
    -D LINK_WITH_PTHREAD=$(usex 'threads' ON OFF) \
    -D MBEDTLS_FATAL_WARNINGS=OFF \
    -D USE_SHARED_MBEDTLS_LIBRARY=ON \
    -D USE_STATIC_MBEDTLS_LIBRARY=$(usex 'static-libs' ON OFF) \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -D ENABLE_TESTING=$(usex 'test' ON OFF) \
    -Wno-dev \
    || die "Failed cmake build"

  DESTDIR="${ED}" cmake --build build --target ${inst} -j "$(nproc)" || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  ldd "$(get_libdir)/libmbedcrypto-3.so" || { use 'static' && true || : die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz