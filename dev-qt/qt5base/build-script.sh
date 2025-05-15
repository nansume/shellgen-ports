#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-22 19:00 UTC - last change
# Build with useflag: -static-libs +shared +ssl -glib -doc -xstub +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Cross-platform application development framework"
HOMEPAGE="https://www.qt.io"
LICENSE="custom / GPLv3 / LGPL / FDL"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
SPN="qtbase-opensource-src"
PV="5.9.4"
SRC_URI="https://download.qt.io/new_archive/qt/${PV%.*}/${PV}/submodules/qtbase-opensource-src-${PV}.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${SPN}-${PV}"
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
  "app-misc/ca-certificates  # openssl" \
  "dev-lang/perl  # optional" \
  "dev-lang/python3  for glib new version" \
  "dev-lang/ruby24  # past ruby26" \
  "dev-libs/expat  # icu,freetype" \
  "dev-libs/glib-compat" \
  "#dev-libs/glib" \
  "dev-libs/icu-compat" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libxml2" \
  "dev-libs/libxslt" \
  "dev-libs/openssl-compat" \
  "#dev-libs/openssl" \
  "dev-perl/digest-perl-md5" \
  "#dev-perl/perl-file-spec  # no required, it part perl." \
  "#dev-perl/perl-getopt-long  # no required, it part perl." \
  "dev-util/gperf" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib" \
  "media-libs/freetype  # fontconfig" \
  "media-libs/fontconfig" \
  "media-libs/giflib" \
  "media-libs/gstreamer1" \
  "media-libs/gst-plugins-base1" \
  "media-libs/mesa  # for opengl" \
  "net-print/cups" \
  "sys-apps/dbus" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/bison" \
  "sys-devel/flex" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-devel/patch" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  "x11-base/xcb-proto" \
  "x11-base/xorg-proto" \
  "x11-libs/libdrm  # for opengl" \
  "x11-libs/libice" \
  "x11-libs/libpciaccess  # for opengl" \
  "x11-libs/libvdpau  # for opengl" \
  "x11-libs/libsm" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxcursor" \
  "x11-libs/libxdamage  # for ?opengl" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxfixes" \
  "x11-libs/libxft" \
  "x11-libs/libxi" \
  "x11-libs/libxinerama  # optional" \
  "x11-libs/libxrandr" \
  "x11-libs/libxrender" \
  "x11-libs/libxshmfence  # for ?opengl" \
  "x11-libs/libxv  # optional" \
  "x11-libs/libxt  # dbus" \
  "x11-libs/libxxf86vm  # for ?opengl" \
  "x11-libs/xtrans" \
  "x11-misc/util-macros" \
  "x11-misc/xkeyboard-config" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc" CXX="c++"

  export QT5DIR="${BUILD_DIR}"
  export LD_LIBRARY_PATH="${QT5DIR}/lib:${LD_LIBRARY_PATH}"
  export QT5PREFIX="/"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  ./configure \
    -prefix "/" \
    -bindir "/$(get_libdir)/qt5/bin" \
    -sysconfdir "/etc/xdg" \
    -libdir "/$(get_libdir)" \
    -archdatadir "/$(get_libdir)/qt5" \
    -plugindir "/$(get_libdir)/qt5/plugins" \
    -importdir "/$(get_libdir)/qt5/imports" \
    -headerdir "/usr/include/qt5" \
    -datadir "/usr/share/qt5" \
    -translationdir "/usr/share/qt5/translations" \
    -docdir "/usr/share/doc/qt5" \
    -examplesdir "/usr/share/doc/qt5/examples" \
    -platform "linux-g++$(usex !x86 -64)" \
    -opensource \
    -confirm-license \
    -release \
    -silent \
    -optimize-size \
    -strip \
    -system-proxies \
    -no-qml-debug \
    -gif \
    -ico \
    -qt-zlib \
    -qt-libpng \
    -qt-libjpeg \
    -qt-harfbuzz \
    -qt-sqlite \
    -qt-pcre \
    -dbus-runtime \
    -glib \
    -icu \
    -openssl-runtime \
    -qt-freetype \
    -qt-xcb \
    -qt-xkbcommon-x11 \
    -cups \
    -qpa xcb \
    -no-evdev \
    -opengl desktop \
    -linuxfb \
    -syslog \
    -no-sse3 \
    -no-ssse3 \
    -no-sse4.1 \
    -no-sse4.2 \
    -no-avx \
    -nomake examples \
    -no-rpath \
    || die "configure... error"

  make -j "$(nproc)" || printf %s\\n 'die "Failed make build"'

  . runverb \
  make INSTALL_ROOT="${ED}" install || printf %s\\n 'die "make install... error"'

  cd "${ED}/" || die "install dir: not found... error"

  mkdir -m 0755 -- "bin/"
  for BIN in $(get_libdir)/qt5/bin/*; do
    ln -s "/$(get_libdir)/qt5/bin/${BIN##*/}" bin/${BIN##*/}-qt5
    printf %s\\n "ln -s /${LIB_DIR}/qt5/bin/${BIN##*/} bin/${BIN##*/}-qt5"
  done

  find "$(get_libdir)/" -name '*.la' -delete || die

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${PN} pkg-create-cgz
