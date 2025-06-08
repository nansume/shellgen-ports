#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-05-25 10:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/media-libs/libjxl/libjxl-0.11.1.ebuild

# BUG: build <shared>+<static-libs> no-support, only <shared> or <static-libs>
# TODO: add static-libs pkg like {pn}-static

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="JPEG XL image format reference implementation"
HOMEPAGE="https://github.com/libjxl/libjxl/"
LICENSE="BSD"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="0.11.1"
SRC_URI="https://github.com/libjxl/libjxl/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-gdk-pixbuf +gif +jpeg -openexr +png -test"
IUSE="${IUSE} (-static-libs) +shared -doc (+musl) +stest +strip"
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
PROG="jxlinfo"

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
  "app-arch/brotli" \
  "dev-build/cmake3" \
  "dev-cpp/highway" \
  "dev-util/pkgconf" \
  "media-libs/giflib" \
  "media-libs/lcms2" \
  "media-libs/libjpeg-turbo3" \
  "media-libs/libpng" \
  "#media-libs/openexr  # it missing" \
  "media-libs/tiff  # deps lcms2" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  "x11-misc/shared-mime-info" \
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
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  cmake -B build -G "Unix Makefiles" \
    -D CMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -D CMAKE_INSTALL_BINDIR="bin" \
    -D CMAKE_INSTALL_LIBDIR="$(get_libdir)" \
    -D CMAKE_INSTALL_INCLUDEDIR="${INCDIR#/}" \
    -D CMAKE_INSTALL_DATAROOTDIR="${DPREFIX#/}/share" \
    -D CMAKE_INSTALL_DOCDIR="${DPREFIX#/}/share/doc" \
    -D CMAKE_BUILD_TYPE="Release" \
    -D JPEGXL_ENABLE_BENCHMARK=OFF \
    -D JPEGXL_ENABLE_COVERAGE=OFF \
    -D JPEGXL_ENABLE_FUZZERS=OFF \
    -D JPEGXL_ENABLE_SJPEG=OFF \
    -D JPEGXL_WARNINGS_AS_ERRORS=OFF \
    -D CMAKE_DISABLE_FIND_PACKAGE_GIF=$(usex !gif ON OFF) \
    -D CMAKE_DISABLE_FIND_PACKAGE_JPEG=$(usex !jpeg ON OFF) \
    -D CMAKE_DISABLE_FIND_PACKAGE_PNG=$(usex !png ON OFF) \
    -D JPEGXL_ENABLE_SKCMS=OFF \
    -D JPEGXL_ENABLE_VIEWERS=OFF \
    -D JPEGXL_FORCE_SYSTEM_BROTLI=ON \
    -D JPEGXL_FORCE_SYSTEM_GTEST=ON \
    -D JPEGXL_FORCE_SYSTEM_HWY=ON \
    -D JPEGXL_FORCE_SYSTEM_LCMS2=ON \
    -D JPEGXL_ENABLE_DOXYGEN=OFF \
    -D JPEGXL_ENABLE_MANPAGES=OFF \
    -D JPEGXL_ENABLE_JNI=OFF \
    -D JPEGXL_ENABLE_JPEGLI=OFF \
    -D JPEGXL_ENABLE_JPEGLI_LIBJPEG=OFF \
    -D JPEGXL_ENABLE_TCMALLOC=OFF \
    -D JPEGXL_ENABLE_EXAMPLES=OFF \
    -D JPEGXL_ENABLE_TOOLS=ON \
    -D JPEGXL_ENABLE_OPENEXR=$(usex 'openexr' ON OFF) \
    -D JPEGXL_ENABLE_PLUGINS=ON \
    -D JPEGXL_ENABLE_PLUGIN_GDKPIXBUF=$(usex 'gdk-pixbuf' ON OFF) \
    -D JPEGXL_ENABLE_PLUGIN_GIMP210=OFF \
    -D JPEGXL_ENABLE_PLUGIN_MIME=OFF \
    -D BUILD_TESTING=$(usex 'test' ON OFF) \
    -D BUILD_SHARED_LIBS=ON \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  DESTDIR="${ED}" cmake --build build --target ${INSTALL_OPTS} -j "$(nproc)" || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'static-libs' || find "$(get_libdir)/" -name '*.a' -delete || : die

  # fix: cmake wrong the pkgconfig
  grep '${prefix}' < $(get_libdir)/pkgconfig/${PN}.pc
  sed -e 's|${prefix}||;s|${exec_prefix}||' -i $(get_libdir)/pkgconfig/*.pc

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"

  use 'stest' && { bin/${PROG} --version || : die "binary work... error";}
  ldd "$(get_libdir)"/${PN}.so || : die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz