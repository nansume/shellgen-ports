#!/bin/sh
# Copyright (C) 2024-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2024-09-11 20:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/media-gfx/feh/feh-3.10.3.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="A fast, lightweight imageviewer using imlib2"
HOMEPAGE="https://feh.finalrewind.org/"
LICENSE="feh"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="3.10.3"
SRC_URI="
  https://feh.finalrewind.org/${PN}-${PV}.tar.bz2
  http://data.gpo.zugaina.org/gentoo/media-gfx/feh/files/feh-3.2-debug-cflags.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-debug +curl +exif -test +xinerama -inotify -static +shared -doc (+musl) +stest +strip"
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
  "dev-libs/gmp  # deps curl" \
  "dev-libs/libtasn1  # deps curl" \
  "dev-libs/libunistring  # deps curl" \
  "dev-libs/nettle  # deps curl" \
  "dev-libs/openssl3  # deps curl" \
  "media-libs/freetype  # deps imlib2" \
  "media-libs/giflib  # deps imlib2" \
  "media-libs/imlib2  # imlib2[X,text]" \
  "media-libs/libexif  # optional for exif" \
  "media-libs/libjpeg-turbo3" \
  "media-libs/libpng" \
  "media-libs/libwebp  # deps imlib2" \
  "media-libs/tiff  # deps imlib2" \
  "net-dns/c-ares  # deps curl" \
  "net-libs/gnutls  # deps curl" \
  "net-misc/curl8  # optional" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl0" \
  "sys-libs/zlib  # for png,cerl" \
  "x11-base/xorg-proto" \
  "x11-libs/libice" \
  "x11-libs/libsm" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxinerama" \
  "x11-libs/libxt" \
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
  if use !shared || use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
    append-ldflags "-s -static --static"
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/${PN}-3.2-debug-cflags.patch

  #use 'static' && sed -e "/^LDLIBS / s/ -lX11 / -lxcb-shm -lxcb -lfreetype -lX11-xcb -lX11 /" -i config.mk
  #export LDLIBS="-lfreetype -lX11"

  for X in all install; do
  JOBS=$(test "${X}" != 'install' && nproc || printf 1)

  make -j "${JOBS}" \
    DESTDIR="${ED}" \
    PREFIX="/usr" \
    ICON_PREFIX="${ED}${EPREFIX%/}"/usr/share/icons \
    bin_dir="${ED}/bin" \
    man_dir='${main_dir}'/share/man \
    doc_dir='${main_dir}'/share/doc/${PN}-${PV} \
    example_dir='${main_dir}'/share/doc/${PN}-${PV}/examples \
    desktop_dir='${main_dir}'/share/applications \
    font_dir='${main_dir}'/share/${PN}/fonts \
    image_dir='${main_dir}'/share/${PN}/images \
    curl=$(usex 'curl' 1 0) \
    debug=$(usex 'debug' 1 0) \
    xinerama=$(usex 'xinerama' 1 0) \
    exif=$(usex 'exif' 1 0) \
    inotify=$(usex 'inotify' 1 0) \
    ${X} \
    || die "Failed make build && make install... error"

  done

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -r -- "usr/share/doc/"

  use 'strip' && strip --verbose --strip-all "bin/${PN}"

  use 'static' && LD_LIBRARY_PATH=
  use 'stest' && { bin/${PN} --version || die "binary work... error";}

  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz