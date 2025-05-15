#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-25 19:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Xine movie player"
HOMEPAGE="https://xine-project.org/home"
LICENSE="GPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="0.99.14"
SRC_URI="https://downloads.sourceforge.net/xine/${PN}-${PV}.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-aalib +curl -debug -libcaca -lirc -nls -readline -vdr +X -xinerama +static -doc (+musl) +stest +strip"
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
ZCOMP="unxz"
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
  "#app-arch/libarchive" \
  "dev-lang/perl" \
  "#dev-libs/expat  # deps opengl" \
  "#dev-libs/glib  # deps xine-lib" \
  "dev-libs/gmp  # deps xine-lib" \
  "#dev-libs/libffi  # deps xine-lib" \
  "dev-libs/libtasn1  # deps xine-lib" \
  "dev-libs/libunistring  # deps xine-lib" \
  "dev-libs/nettle  # deps xine-lib" \
  "#dev-libs/pcre  # deps xine-lib" \
  "dev-libs/openssl3  # deps curl" \
  "dev-util/pkgconf" \
  "media-gfx/imagemagick  # deps xine-lib" \
  "#media-libs/a52dec  # deps xine-lib" \
  "media-libs/alsa-lib  # deps xine-lib" \
  "#media-libs/glu  # deps xine-lib" \
  "#media-libs/faad2  # deps xine-lib" \
  "media-libs/flac  # deps xine-lib" \
  "#media-libs/fontconfig  # deps xine-lib" \
  "#media-libs/freetype  # deps xine-lib" \
  "media-libs/libjpeg-turbo" \
  "media-libs/libpng" \
  "media-libs/libogg  # deps xine-lib" \
  "#media-libs/libmad  # deps xine-lib" \
  "media-libs/libvorbis  # deps xine-lib" \
  "media-libs/libvpx  # deps xine-lib" \
  "#media-libs/mesa  # deps xine-lib" \
  "media-libs/sdl  # deps xine-lib" \
  "media-libs/xine-lib" \
  "media-video/ffmpeg  # deps xine-lib" \
  "net-libs/gnutls  # deps xine-lib" \
  "net-libs/libssh2  # deps xine-lib" \
  "net-libs/mbedtls  # deps xine-lib" \
  "net-misc/curl  # curl?" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "#sys-libs/ncurses  # readline?" \
  "#sys-libs/readline  # readline?" \
  "sys-libs/zlib" \
  "x11-base/xorg-proto" \
  "#x11-libs/libdrm  # opengl?" \
  "#x11-libs/libpciaccess  # opengl?" \
  "x11-libs/libice" \
  "x11-libs/libsm" \
  "x11-libs/libx11" \
  "x11-libs/libxau  # for x11" \
  "x11-libs/libxcb  # for x11" \
  "#x11-libs/libxdamage  # opengl?" \
  "x11-libs/libxdmcp  # for x11" \
  "x11-libs/libxext" \
  "x11-libs/libxfixes" \
  "#x11-libs/libxft" \
  "x11-libs/libxi" \
  "x11-libs/libxrandr" \
  "x11-libs/libxrender" \
  "#x11-libs/libxshmfence  # opengl?" \
  "x11-libs/libxscrnsaver" \
  "x11-libs/libxt" \
  "x11-libs/libxtst" \
  "x11-libs/libxv" \
  "x11-libs/libxxf86vm" \
  "#x11-libs/libxinerama  # xinerama?" \
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
  if use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc$(usex static ' --static')"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  rm -- misc/xine-bugreport || die

  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --without-tar \
    --disable-xinerama \
    --disable-lirc \
    --disable-vdr-keys \
    --disable-nvtvsimple \
    --disable-debug \
    --disable-xft \
    $(use_with 'X' x) \
    --without-readline \
    $(use_with 'curl') \
    --without-aalib \
    --without-caca \
    --with-fb \
    --disable-nls \
    --disable-rpath \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make \
    DESTDIR="${ED}" \
    docdir="/usr/share/doc/${PN}-${PV}" \
    docsdir="/usr/share/doc/${PN}-${PV}" \
    ${INSTALL_OPTS} \
    || die "make install... error"

  : einstalldocs

  cd "${ED}/" || die "install dir: not found... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
