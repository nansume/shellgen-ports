#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2024-11-15 19:00 UTC - last change
# Build with useflag: -static -static-libs -shared -lfs +nopie -patch -doc -xstub -diet -musl -stest -strip +noarch

# http://data.gpo.zugaina.org/gentoo/dev-libs/rapidjson/rapidjson-1.1.0-r4.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="A fast JSON parser/generator for C++ with both SAX/DOM style API"
HOMEPAGE="https://rapidjson.org/"
LICENSE="MIT"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="1.1.0"
SRC_URI="
  https://github.com/miloyip/rapidjson/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/dev-libs/rapidjson/files/rapidjson-1.1.0-gcc-7.patch
  http://data.gpo.zugaina.org/gentoo/dev-libs/rapidjson/files/rapidjson-1.1.0-system_gtest.patch
  http://data.gpo.zugaina.org/gentoo/dev-libs/rapidjson/files/rapidjson-1.1.0-valgrind_optional.patch
  http://data.gpo.zugaina.org/gentoo/dev-libs/rapidjson/files/rapidjson-1.1.0-gcc14-const.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-doc -examples -test"
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
  "dev-util/cmake" \
  "dev-util/pkgconf" \
  "sys-devel/binutils  # for build tests (required)" \
  "sys-devel/gcc9  # for build tests (required)" \
  "sys-libs/musl  # for build tests (required)" \
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
  if use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}/${PN}-${PV}-gcc-7.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-${PV}-system_gtest.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-${PV}-valgrind_optional.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-${PV}-gcc14-const.patch"

  sed -e 's| -march=native||g' -i CMakeLists.txt || die
  sed -e 's| -Werror||g' -i CMakeLists.txt example/CMakeLists.txt test/unittest/CMakeLists.txt || die

  cmake -B build -G Ninja \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}/usr" \
    -DLIB_INSTALL_DIR="${EPREFIX%/}/lib" \
    -DDOC_INSTALL_DIR="${EPREFIX%/}/usr/share/doc/${PN}-${PV}" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DRAPIDJSON_BUILD_CXX11="OFF" \
    -DRAPIDJSON_BUILD_DOC=$(usex 'doc') \
    -DRAPIDJSON_BUILD_EXAMPLES=$(usex 'examples') \
    -DRAPIDJSON_BUILD_TESTS=$(usex 'test') \
    -DRAPIDJSON_BUILD_THIRDPARTY_GTEST="OFF" \
    -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  ninja -j "$(nproc)" -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${ED}" cmake --install build $(usex 'strip' --strip) || die "make install... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="all" PN=${XPN} PV=${PV} pkg-create-cgz
