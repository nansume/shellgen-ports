#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2024-07-27 22:00 UTC, 2025-05-19 09:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# https://data.gpo.zugaina.org/gentoo/media-video/qmplay2/qmplay2-25.01.19.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="A Qt-based video player, which can play most formats and codecs"
HOMEPAGE="https://github.com/zaps166/QMPlay2"
LICENSE="LGPL-3"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="25.01.19"  # min ver: qt-5.15.2
PV="20.12.16"
PV="24.04.07"
SRC_URI="https://github.com/zaps166/QMPlay2/releases/download/${PV}/QMPlay2-src-${PV}.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-static -static-libs +shared -doc (+musl) +stest +strip"
IUSE="${IUSE} +avdevice +audiofilters +alsa -cdio -cuvid +extensions -gme -inputs +libass"
IUSE="${IUSE} -modplug -notifications -opengl -pipewire -portaudio -pulseaudio +qt5 -qt6 -sid"
IUSE="${IUSE} -shaders +taglib -vaapi -videofilters -visualizations -vulkan +xv"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/QMPlay2-src-${PV}"
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
PROG="QMPlay2"

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
  "dev-lang/perl  # optional" \
  "dev-libs/expat  # icu,freetype,libass" \
  "dev-libs/fribidi  # deps libass" \
  "dev-libs/glib74" \
  "dev-libs/icu64  # deps qt5base" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libxml2-1" \
  "dev-libs/libxslt" \
  "dev-libs/pcre2  # for glib74" \
  "dev-qt/qt5base12" \
  "dev-qt/qt5declarative12  # extensions?" \
  "dev-qt/qt5svg12" \
  "dev-qt/qt5x11extras12" \
  "dev-qt/qt5tools12" \
  "dev-util/cmake" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib" \
  "media-video/ffmpeg7" \
  "media-libs/freetype  # fontconfig" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz2-2  # deps libass" \
  "media-libs/libass" \
  "media-libs/taglib" \
  "media-libs/mesa  # for opengl" \
  "sys-apps/dbus # ?no-required" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
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
  "x11-libs/libxrandr" \
  "x11-libs/libxrender" \
  "x11-libs/libxv  # optional" \
  "x11-libs/libxshmfence" \
  "x11-libs/libxxf86vm" \
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
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  if use !shared && { use 'static-libs' || use 'static' ;}; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
    append-ldflags "-s -static --static"
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc" CXX="c++"

  use 'strip' && INSTALL_OPTS="install/strip"

  mkdir -pm 0755 -- "${BUILD_DIR}/build/"
  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  cmake \
    -GNinja -B build -S . \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -DCMAKE_INSTALL_BINDIR="${EPREFIX%/}/bin" \
    -DCMAKE_INSTALL_SYSCONFDIR="etc" \
    -DCMAKE_INSTALL_LIBDIR="${EPREFIX%/}/$(get_libdir)" \
    -DCMAKE_INSTALL_INCLUDEDIR="${INCDIR}" \
    -DCMAKE_INSTALL_DATAROOTDIR="${DPREFIX}/share" \
    -DCMAKE_INSTALL_MANDIR="${DPREFIX}/share/man" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DBUILD_WITH_QT6=$(usex 'qt6' ON OFF) \
    -DUSE_UPDATES="OFF" \
    -DUSE_ALSA=$(usex 'alsa' ON OFF) \
    -DUSE_AUDIOCD=$(usex 'cdio' ON OFF) \
    -DUSE_DBUS_PM="OFF" \
    -DUSE_FREEDESKTOP_NOTIFICATIONS="ON" \
    -DUSE_LIBASS=$(usex 'libass' ON OFF) \
    -DUSE_NOTIFY=$(usex 'notifications' ON OFF) \
    -DUSE_OPENGL=$(usex 'opengl' ON OFF) \
    -DUSE_VULKAN=$(usex 'vulkan' ON OFF) \
    -DUSE_GLSLC=$(usex 'shaders' ON OFF) \
    -DUSE_XVIDEO=$(usex 'xv' ON OFF) \
    -DUSE_FFMPEG_AVDEVICE=$(usex 'avdevice' ON OFF) \
    -DUSE_FFMPEG_VAAPI=$(usex 'vaapi' ON OFF) \
    -DUSE_CHIPTUNE_GME=$(usex 'gme' ON OFF) \
    -DUSE_CHIPTUNE_SID=$(usex 'sid' ON OFF) \
    -DUSE_AUDIOFILTERS=$(usex 'audiofilters' ON OFF) \
    -DUSE_CUVID=$(usex 'cuvid' ON OFF) \
    -DUSE_INPUTS=$(usex 'inputs' ON OFF) \
    -DUSE_MODPLUG=$(usex 'modplug' ON OFF) \
    -DUSE_PIPEWIRE=$(usex 'pipewire' ON OFF) \
    -DUSE_PORTAUDIO=$(usex 'portaudio' ON OFF) \
    -DUSE_PULSEAUDIO=$(usex 'pulseaudio' ON OFF) \
    -DUSE_TAGLIB=$(usex 'taglib' ON OFF) \
    -DUSE_VIDEOFILTERS=$(usex 'videofilters' ON OFF) \
    -DUSE_VISUALIZATIONS=$(usex 'visualizations' ON OFF) \
    -DUSE_EXTENSIONS=$(usex 'extensions' ON OFF) \
    -DUSE_LASTFM="ON" \
    -DUSE_LYRICS="ON" \
    -DUSE_MEDIABROWSER="ON" \
    -DUSE_MPRIS2="ON" \
    -DUSE_GIT_VERSION="false" \
    -DBUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -DCMAKE_SKIP_INSTALL_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    .. || die "Failed cmake build"

  ninja -j "$(nproc)" -C "${BUILD_DIR}/build" || die "Build... Failed"

  #DESTDIR="${ED}" ninja -C "build" ${INSTALL_OPTS} || die "make install... error"
  DESTDIR="${ED}" cmake --install build $(usex 'strip' --strip) || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -r -- "usr/share/man/"

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"

  use 'stest' && { bin/${PROG} --version || : die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || : die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz