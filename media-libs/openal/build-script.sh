#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-04-08 19:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# BUG: c1plus: warning: unrecognized command line option `-Wno-c++20-attribute-extensions`
# ?FIX: add -DCMAKE_CXX_STANDARD=14 \

# http://data.gpo.zugaina.org/gentoo/media-libs/openal/openal-1.24.2.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="A software implementation of the OpenAL 3D audio API"
HOMEPAGE="https://www.openal-soft.org/"
LICENSE="LGPL-2+ BSD"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="1.24.2"
SRC_URI="https://www.openal-soft.org/openal-releases/${PN}-soft-${PV}.tar.bz2"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+alsa -coreaudio -debug -jack -oss -pipewire -portaudio -pulseaudio -sdl -sndio -qt5"
IUSE="${IUSE} +cpu_flags_x86_sse +cpu_flags_x86_sse2 -cpu_flags_x86_sse4_1 -cpu_flags_arm_neon"
IUSE="${IUSE} -sse3 -static -static-libs +shared -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-soft-${PV}"
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
PROG="${PN}-info"

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
  "dev-util/cmake" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl0" \
  "sys-libs/zlib  # optional" \
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
  if use !shared && use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  cmake -B build -G "Unix Makefiles" \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}/usr" \
    -DCMAKE_INSTALL_BINDIR="${EPREFIX%/}/bin" \
    -DCMAKE_INSTALL_LIBDIR="${EPREFIX%/}/$(get_libdir)" \
    -DCMAKE_INSTALL_INCLUDEDIR="${INCDIR}" \
    -DCMAKE_INSTALL_DATAROOTDIR="${DPREFIX}/share" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_CXX_STANDARD="14" \
    -DALSOFT_BACKEND_ALSA=$(usex 'alsa') \
    -DALSOFT_REQUIRE_ALSA=$(usex 'alsa') \
    -DALSOFT_BACKEND_COREAUDIO=$(usex 'coreaudio') \
    -DALSOFT_REQUIRE_COREAUDIO=$(usex 'coreaudio') \
    -DALSOFT_BACKEND_JACK=$(usex 'jack') \
    -DALSOFT_REQUIRE_JACK=$(usex 'jack') \
    -DALSOFT_BACKEND_OSS=$(usex 'oss') \
    -DALSOFT_REQUIRE_OSS=$(usex 'oss') \
    -DALSOFT_BACKEND_PIPEWIRE=$(usex 'pipewire') \
    -DALSOFT_REQUIRE_PIPEWIRE=$(usex 'pipewire') \
    -DALSOFT_BACKEND_PORTAUDIO=$(usex 'portaudio') \
    -DALSOFT_REQUIRE_PORTAUDIO=$(usex 'portaudio') \
    -DALSOFT_BACKEND_PULSEAUDIO=$(usex 'pulseaudio') \
    -DALSOFT_REQUIRE_PULSEAUDIO=$(usex 'pulseaudio') \
    -DALSOFT_BACKEND_SDL2=$(usex 'sdl') \
    -DALSOFT_REQUIRE_SDL2=$(usex 'sdl') \
    -DALSOFT_BACKEND_SNDIO=$(usex 'sndio') \
    -DALSOFT_REQUIRE_SNDIO=$(usex 'sndio') \
    -DALSOFT_UTILS=ON \
    -DALSOFT_NO_CONFIG_UTIL=$(usex 'qt5' OFF ON)  \
    -DALSOFT_EXAMPLES=OFF \
    -DALSOFT_CPUEXT_SSE=$(usex 'cpu_flags_x86_sse') \
    -DALSOFT_CPUEXT_SSE2=$(usex 'cpu_flags_x86_sse2') \
    -DALSOFT_CPUEXT_SSE3=$(usex 'sse3') \
    -DALSOFT_CPUEXT_SSE4_1=$(usex 'cpu_flags_x86_sse4_1') \
    -DALSOFT_CPUEXT_NEON=$(usex 'cpu_flags_arm_neon') \
    -DBUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  DESTDIR="${ED}" cmake --build build --target ${INSTALL_OPTS} -j "$(nproc)" || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'stest' && { bin/${PROG} --version || : die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz