#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-27 22:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

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
PV="20.12.16"
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
IUSE="${IUSE} -modplug -notifications -opengl -pipewire -portaudio -pulseaudio -qt6 -sid"
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
  "dev-lang/perl  # optional" \
  "dev-libs/expat  # icu,freetype,libass" \
  "dev-libs/fribidi  # deps libass" \
  "dev-libs/glib-compat" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/icu-compat  # deps qt5base" \
  "dev-libs/libxml2" \
  "dev-libs/libxslt" \
  "dev-qt/qt5base" \
  "dev-qt/qt5declarative  # extensions?" \
  "dev-qt/qt5svg" \
  "dev-qt/qt5x11extras" \
  "dev-qt/qt5tools" \
  "dev-util/cmake" \
  "dev-util/ninja" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib" \
  "media-video/ffmpeg" \
  "media-libs/freetype  # fontconfig" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz  # deps libass" \
  "media-libs/libass" \
  "media-libs/taglib" \
  "media-libs/mesa  # for opengl" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
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
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc$(usex static ' --static')"
  CXX="c++$(usex static ' --static')"

  use 'strip' && INSTALL_OPTS="install/strip"

  mkdir -pm 0755 -- "${BUILD_DIR}/build/"
  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  cmake \
    -GNinja -B build -S . \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -DCMAKE_INSTALL_BINDIR="${EPREFIX%/}/bin" \
    -DCMAKE_INSTALL_SBINDIR="sbin" \
    -DCMAKE_INSTALL_SYSCONFDIR="etc" \
    -DCMAKE_INSTALL_LIBDIR="${EPREFIX%/}/$(get_libdir)" \
    -DCMAKE_INSTALL_INCLUDEDIR="${INCDIR}" \
    -DCMAKE_INSTALL_LIBEXECDIR="${DPREFIX}/libexec" \
    -DCMAKE_INSTALL_DATAROOTDIR="${DPREFIX}/share" \
    -DCMAKE_INSTALL_DOCDIR="${DPREFIX}/share/doc" \
    -DCMAKE_INSTALL_MANDIR="${DPREFIX}/share/man" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DBUILD_WITH_QT6=$(usex 'qt6') \
    -DUSE_UPDATES="OFF" \
    -DUSE_ALSA=$(usex 'alsa') \
    -DUSE_AUDIOCD=$(usex 'cdio') \
    -DUSE_DBUS_PM="OFF" \
    -DUSE_FREEDESKTOP_NOTIFICATIONS="ON" \
    -DUSE_LIBASS=$(usex 'libass') \
    -DUSE_NOTIFY=$(usex 'notifications') \
    -DUSE_OPENGL=$(usex 'opengl') \
    -DUSE_VULKAN=$(usex 'vulkan') \
    -DUSE_GLSLC=$(usex 'shaders') \
    -DUSE_XVIDEO=$(usex 'xv') \
    -DUSE_FFMPEG_AVDEVICE=$(usex 'avdevice') \
    -DUSE_FFMPEG_VAAPI=$(usex 'vaapi') \
    -DUSE_CHIPTUNE_GME=$(usex 'gme') \
    -DUSE_CHIPTUNE_SID=$(usex 'sid') \
    -DUSE_AUDIOFILTERS=$(usex 'audiofilters') \
    -DUSE_CUVID=$(usex 'cuvid') \
    -DUSE_INPUTS=$(usex 'inputs') \
    -DUSE_MODPLUG=$(usex 'modplug') \
    -DUSE_PIPEWIRE=$(usex 'pipewire') \
    -DUSE_PORTAUDIO=$(usex 'portaudio') \
    -DUSE_PULSEAUDIO=$(usex 'pulseaudio') \
    -DUSE_TAGLIB=$(usex 'taglib') \
    -DUSE_VIDEOFILTERS=$(usex 'videofilters') \
    -DUSE_VISUALIZATIONS=$(usex 'visualizations') \
    -DUSE_EXTENSIONS=$(usex 'extensions') \
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

  ninja -C "build" || die "Failed make build"
  DESTDIR="${ED}" ninja -C "build" ${INSTALL_OPTS} || die "make install... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
