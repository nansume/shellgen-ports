#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-05-17 10:00 UTC - last change
# Build with useflag: -static-libs +shared -ssl +glib +python -doc -xstub +musl +stest +strip +x32

# BUG: WARNING: Failure to find: qt5qml_metatypes.json
# BUG: WARNING: Failure to find: /build/qtdeclarative-everywhere-src-5.15.16/src/qml/qt5qml_metatypes.json

# http://data.gpo.zugaina.org/gentoo/dev-qt/qtdeclarative/qtdeclarative-5.15.16.ebuild

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
PN=${PN%[0-9]*}
SPN="qtdeclarative-everywhere-src"
PV="5.15.16"
PV="5.12.12"
BASE_URI="data.gpo.zugaina.org/gentoo/dev-qt/qtdeclarative"
SRC_URI="https://download.qt.io/archive/qt/${PV%.*}/${PV}/submodules/${SPN}-${PV}.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-gles2-only -jit -localstorage -vulkan -widgets"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/qtdeclarative-everywhere-src-${PV}"
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
  "dev-db/sqlite3" \
  "dev-lang/ruby26" \
  "dev-lang/perl  # optional" \
  "dev-lang/python3-8  # for qt5base[qtqml],glib" \
  "dev-libs/expat  # icu,freetype" \
  "dev-libs/glib74" \
  "dev-libs/gmp  # for ssl" \
  "dev-libs/icu64  # deps qt5base" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libxml2-1" \
  "dev-libs/libxslt" \
  "dev-libs/pcre2  # for glib74" \
  "dev-libs/openssl3" \
  "dev-perl/digest-perl-md5" \
  "dev-qt/qt5base12" \
  "dev-util/gperf" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib" \
  "media-libs/freetype  # fontconfig" \
  "media-libs/fontconfig" \
  "media-libs/giflib" \
  "#media-libs/gstreamer1" \
  "#media-libs/gst-plugins-base1" \
  "media-libs/harfbuzz2-2" \
  "media-libs/libjpeg-turbo3" \
  "media-libs/libpng" \
  "media-libs/mesa  # for opengl" \
  "net-print/cups" \
  "sys-apps/dbus" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/bison" \
  "sys-devel/flex" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  "x11-base/xcb-proto" \
  "x11-base/xorg-proto" \
  "x11-libs/libdrm  # for opengl" \
  "x11-libs/libice" \
  "x11-libs/libpciaccess  # for opengl" \
  "x11-libs/libsm" \
  "x11-libs/libvdpau  # for opengl" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxcursor" \
  "x11-libs/libxdamage  # for opengl" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxfixes" \
  "x11-libs/libxft" \
  "x11-libs/libxi" \
  "x11-libs/libxinerama  # optional" \
  "x11-libs/libxrandr" \
  "x11-libs/libxrender" \
  "x11-libs/libxv  # optional" \
  "x11-libs/libxshmfence" \
  "x11-libs/libxxf86vm" \
  "x11-libs/xcb-util  # ?for xcb" \
  "x11-libs/xcb-util-cursor" \
  "x11-libs/xcb-util-image  # ?for xcb" \
  "x11-libs/xcb-util-keysyms  # ?for xcb" \
  "x11-libs/xcb-util-renderutil  # ?for xcb" \
  "x11-libs/xcb-util-wm  # ?for xcb" \
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

  . "${PDIR%/}/etools.d/"epython

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc" CXX="c++"
  PATH="${PATH:+${PATH}:}/$(get_libdir)/qt5/bin"  # optional (no-required)

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  #patch -p1 -E < "${FILESDIR}"/qtdeclarative-5.14.2-QQuickItemView-fix-maxXY-extent.patch

  mkdir -m 0755 -- ".git/"

  qmake-qt5
  make -j "$(nproc)" || printf %s\\n 'die "Failed make build"'

  . runverb \
  make INSTALL_ROOT="${ED}" install || printf %s\\n 'die "make install... error"'

  cd "${ED}/" || die "install dir: not found... error"

  sed -e 's|${prefix}|/|g' -i "$(get_libdir)/"pkgconfig/Qt5*.pc
  sed -e '/^QMAKE_PRL_BUILD_DIR/d' -i "$(get_libdir)/"libQt5*.prl

  find "$(get_libdir)/" -name '*.la' -delete || die

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz