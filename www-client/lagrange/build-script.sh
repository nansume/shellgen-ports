#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-05-04 18:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs -nopie -patch -doc -xstub -diet +musl -stest +strip +x32

# BUG: if compile with buildflag +gui [sdl], then build failed.
# BUG: error: `SDL_HINT_MAC_BACKGROUND_APP` undeclared

# http://data.gpo.zugaina.org/guru/net-client/lagrange/lagrange-1.18.5.ebuild
# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=lagrange

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="Beautiful Gemini Client"
HOMEPAGE="https://gmi.skyjake.fi/lagrange/ https://git.skyjake.fi/gemini/lagrange"
LICENSE="|| ( MIT Unlicense ) Apache-2.0 BSD-2 CC-BY-SA-4.0 OFL-1.1"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="1.18.5"
SRC_URI="https://git.skyjake.fi/gemini/${PN}/releases/download/v${PV}/${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-X -bidi -debug -gui +harfbuzz +mp3 +ncurses +opus +webp +static -shared -doc (+musl) +strip"
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
PROG="clagrange"

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
  "app-arch/zip" \
  "dev-libs/glib74  # deps harfbuzz" \
  "dev-libs/gmp  # deps ssl,curl" \
  "dev-libs/icu64  # deps harfbuzz" \
  "dev-libs/libffi  # for harfbuzz" \
  "dev-libs/libunistring" \
  "#dev-libs/pcre" \
  "dev-libs/pcre2" \
  "dev-libs/openssl3" \
  "#dev-libs/sealcurses" \
  "#dev-libs/tfdn" \
  "dev-util/cmake" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib  # deps sdl2" \
  "media-libs/freetype  # for harfbuzz" \
  "media-libs/harfbuzz2-1" \
  "media-libs/libwebp" \
  "media-libs/libogg  # deps opusfile" \
  "media-libs/opus  # deps opusfile" \
  "media-libs/opusfile" \
  "media-libs/sdl2" \
  "media-sound/mpg123" \
  "net-dns/c-ares  # deps curl" \
  "net-misc/curl8-2" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/ncurses" \
  "sys-libs/zlib" \
  "#x11-base/xorg-proto" \
  "#x11-libs/libx11" \
  "#x11-libs/libxau" \
  "#x11-libs/libxcb" \
  "#x11-libs/libxdmcp" \
  "#x11-libs/libxext" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  # FIX: at cmake wrong path to include: //include
  # TODO: fix it by rightly path: /usr/include
  ln -s /usr/include /include
  # FIX: libiconv.a needed by static build
  ln -s libc.a "/$(get_libdir)/"libiconv.a
fi

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
  append-ldflags "-s -static --static"
  append-cflags -ffunction-sections -fdata-sections
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  append-cppflags $(usex debug "-UNDEBUG" "-DNDEBUG")

  CC="gcc"

  use 'strip' && INSTALL_OPTS="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # remove libs that can be accidentally built by Depends.cmake
  #mv -n lib never-build-bundled-libs || die

  cmake -B build -G "Unix Makefiles" \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -DCMAKE_INSTALL_BINDIR="bin" \
    -DCMAKE_INSTALL_DATAROOTDIR="${DPREFIX#/}/share" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DENABLE_KERNING=OFF \
    -DTFDN_ENABLE_SSE41=OFF \
    -DENABLE_GUI=$(usex 'gui' ON OFF) \
    -DENABLE_TUI=$(usex 'ncurses' ON OFF) \
    -DENABLE_FRIBIDI=$(usex 'bidi' ON OFF) \
    -DENABLE_HARFBUZZ=$(usex 'harfbuzz' ON OFF) \
    -DENABLE_MPG123=$(usex 'mp3' ON OFF) \
    -DENABLE_OPUS=$(usex 'opus' ON OFF) \
    -DENABLE_WEBP=$(usex 'webp' ON OFF) \
    -DENABLE_X11_XLIB=$(usex 'X' ON OFF) \
    -DENABLE_POPUP_MENUS=OFF \
    -DENABLE_RESIZE_DRAW=OFF \
    -DENABLE_FRIBIDI_BUILD=OFF \
    -DENABLE_HARFBUZZ_MINIMAL=OFF \
    -DTFDN_ENABLE_WARN_ERROR=OFF \
    -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  DESTDIR="${ED}" cmake --build build --target ${INSTALL_OPTS} -j "$(nproc)" || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -r -- "usr/share/man/"

  use 'stest' && { bin/${PROG} --version || die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz