#!/bin/sh
# Copyright (C) 2024-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2024-11-09 19:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/media-libs/libjpeg-turbo/libjpeg-turbo-3.0.4.ebuild
# https://git.alpinelinux.org/aports/plain/main/libjpeg-turbo/APKBUILD

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="MMX, SSE, and SSE2 SIMD accelerated JPEG library"
HOMEPAGE="https://libjpeg-turbo.org/ https://github.com/libjpeg-turbo/libjpeg-turbo"
LICENSE="BSD IJG ZLIB java? ( GPL-2-with-classpath-exception )"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
PV="3.0.4"
SRC_URI="
  https://github.com/libjpeg-turbo/${PN}/releases/download/${PV}/${PN}-${PV}.tar.gz
  #mirror://gentoo/libjpeg8_8d-2.debian.tar.gz
  rsync://mirror.bytemark.co.uk/gentoo/distfiles/*/libjpeg8_8d-2.debian.tar.gz
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
IUSE="-java +static-libs +shared -doc (+musl) +stest +strip"
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
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
CMAKE_PREFIX_PATH="/${LIB_DIR}/cmake"
PROG="cjpeg"

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
  "dev-build/samurai  # alternative for ninja" \
  "dev-lang/nasm" \
  "dev-util/cmake" \
  "dev-util/pkgconf" \
  "net-misc/rsync" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-libs/musl0" \
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
  if use !shared && use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  CFLAGS="${CFLAGS} -O2 -DNDEBUG" \
  CXXFLAGS="${CXXFLAGS} -O2 -DNDEBUG" \
  cmake -B build -G Ninja \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}/usr" \
    -DCMAKE_INSTALL_BINDIR="${EPREFIX%/}/bin" \
    -DCMAKE_INSTALL_LIBDIR="${EPREFIX%/}/$(get_libdir)" \
    -DCMAKE_INSTALL_INCLUDEDIR="${INCDIR}" \
    -DCMAKE_INSTALL_DATAROOTDIR="${DPREFIX}/share" \
    -DCMAKE_INSTALL_DOCDIR="${DPREFIX}/share/doc" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DENABLE_STATIC=$(usex 'static-libs' True False) \
    -DWITH_JPEG8="1" \
    -DBUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  ninja -j "$(nproc)" -C "${BUILD_DIR}/build" || die "Build... Failed"
  #cmake --build build --target ${INSTALL_OPTS}

  DESTDIR="${ED}" cmake --install build --strip || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -r -- "usr/share/"

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'stest' && { bin/${PROG} --version || : die "binary work... error";}

  ldd "bin/${PROG}" || { use 'static' && true || : die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz