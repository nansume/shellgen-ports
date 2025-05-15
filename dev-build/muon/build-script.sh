#!/bin/sh
# Copyright (C) 2024-2025 Artjom Slepnjov, Shellgen
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-10-24 21:00 UTC - last change
# Date: 2024-11-09 23:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=muon-meson
# http://data.gpo.zugaina.org/gentoo/dev-build/muon/muon-0.4.0.ebuild
# https://github.com/muon-build/muon/blob/master/meson_options.txt

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="A meson-compatible build system"
HOMEPAGE="https://muon.build/"
LICENSE="GPL-3"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="0.5.0"  # meson compatibility version 1.5.99
PN1="pkgconf"
PV1="1.9.5"
SRC_URI="https://muon.build/releases/v${PV}/${PN}-v${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-archive -curl -libpkgconf -test -bootstrap +static -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-v${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
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
  "dev-build/muon  # needed from v0.4.0 - alternative for meson" \
  "dev-build/samurai  # alternative for ninja" \
  "dev-util/pkgconf  # is without <libpkgconf>" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/m4  # required for ninja" \
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
  append-ldflags -Wl,--gc-sections
  append-ldflags "-s -static --static"
  append-cflags -ffunction-sections -fdata-sections
  append-flags -Os -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" MESON="muon"

  mkdir -m 0755 -- "${BUILD_DIR}/build/"
  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  [ -x "/bin/meson" ] && use !bootstrap || {
  MESON="build-stage2/muon"

  ./bootstrap.sh build-stage1 || die "Build stage1... Failed"

  build-stage1/muon-bootstrap setup \
    -D libarchive="disabled" \
    -D libcurl="disabled" \
    -D pkgconfig="exec" \
    -D man-pages="disabled" \
    -D meson-docs="disabled" \
    -D meson-tests="disabled" \
    -D readline="builtin" \
    -D samurai="disabled" \
    -D static="true" \
    -D tracy="disabled" \
    -D ui="disabled" \
    -D website="disabled" \
    "${BUILD_DIR}/build-stage2" \
    || die "meson setup... error"

  ninja -j "$(nproc)" -C "${BUILD_DIR}/build-stage2" || die "Build stage2... Failed"
  }

  ${MESON} setup \
    -D wrap_mode="nodownload" \
    -D buildtype="release" \
    -D prefix="${EPREFIX%/}/" \
    -D bindir="bin" \
    -D ui="disabled" \
    -D website="disabled" \
    -D libcurl="disabled" \
    -D libarchive="disabled" \
    -D pkgconfig=$(usex 'libpkgconf' libpkgconf exec) \
    -D man-pages="disabled" \
    -D meson-docs="disabled" \
    -D meson-tests="disabled" \
    -D tracy="disabled" \
    -D samurai="disabled" \
    -D readline="builtin" \
    -D b_lto="true" \
    -D b_pie="false" \
    -D static="true" \
    "${BUILD_DIR}/build" \
    || die "meson setup... error"

  ninja -j "$(nproc)" -C "${BUILD_DIR}/build" || die "Build stage3 (final)... Failed"

  DESTDIR="${ED}" ./build/muon -C "${BUILD_DIR}/build" install -d "${ED}" || die "meson install... error"

  cd "${ED}/" || die "install dir: not found... error"

  #FIX: strip with meson is there have large size for binary, therefore leave it.
  use 'strip' && strip --verbose --strip-all bin/${PN}

  use 'stest' && { bin/${PN} version || die "binary work... error";}
  ldd "bin/${PN}"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz