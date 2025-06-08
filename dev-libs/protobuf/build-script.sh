#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-05-28 21:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-libs/protobuf/protobuf-30.2.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="Google's Protocol Buffers - Extensible mechanism for serializing structured data"
HOMEPAGE="https://protobuf.dev/"
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
PV="30.2"
#PV="29.4"
SRC_URI="
  https://github.com/protocolbuffers/protobuf/releases/download/v${PV}/${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/dev-libs/protobuf/files/${PN}-23.3-static_assert-failure.patch
  http://data.gpo.zugaina.org/gentoo/dev-libs/protobuf/files/${PN}-28.0-disable-test_upb-lto.patch
  http://data.gpo.zugaina.org/gentoo/dev-libs/protobuf/files/${PN}-30.0-findJsonCpp.patch
  http://data.gpo.zugaina.org/gentoo/dev-libs/protobuf/files/${PN}-27.4-findJsonCpp.patch
  http://data.gpo.zugaina.org/gentoo/dev-libs/${PN}/files/FindJsonCpp.cmake -> ${PN}-FindJsonCpp.cmake
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-conformance -debug -emacs -examples +libprotoc -libupb +protobuf +protoc -test -zlib"
IUSE="${IUSE} -static -static-libs +shared -doc (+musl) +stest +strip"
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
PROG="protoc"

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
  "dev-cpp/abseil-cpp1" \
  "dev-build/cmake4" \
  "dev-build/samurai  # alternative for ninja" \
  "dev-util/pkgconf" \
  "#dev-libs/jsoncpp  # conformance" \
  "sys-devel/binutils" \
  "sys-devel/gcc14" \
  "#sys-devel/make" \
  "sys-libs/musl" \
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

  cp "${FILESDIR}/${PN}-FindJsonCpp.cmake" "${BUILD_DIR}/cmake" || die

  patch -p1 -E < "${FILESDIR}/${PN}-23.3-static_assert-failure.patch"
  #patch -p1 -E < "${FILESDIR}/${PN}-27.4-findJsonCpp.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-28.0-disable-test_upb-lto.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-30.0-findJsonCpp.patch"

  cmake -B build -G Ninja \
    -D CMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -D CMAKE_INSTALL_BINDIR="bin" \
    -D CMAKE_INSTALL_LIBDIR="$(get_libdir)" \
    -D CMAKE_INSTALL_INCLUDEDIR="${INCDIR#/}" \
    -D CMAKE_INSTALL_DATAROOTDIR="${DPREFIX#/}/share" \
    -D CMAKE_INSTALL_DOCDIR="${DPREFIX#/}/share/doc" \
    -D CMAKE_BUILD_TYPE="Release" \
    -D protobuf_ABSL_PROVIDER="package" \
    -D protobuf_JSONCPP_PROVIDER="package" \
    -D protobuf_BUILD_CONFORMANCE=$(usex 'test' $(usex 'conformance' ON OFF) OFF) \
    -D protobuf_BUILD_LIBPROTOC=$(usex 'libprotoc' ON OFF) \
    -D protobuf_BUILD_LIBUPB=$(usex 'libupb' ON OFF) \
    -D protobuf_BUILD_PROTOBUF_BINARIES=$(usex 'protobuf' ON OFF) \
    -D protobuf_BUILD_PROTOC_BINARIES=$(usex 'protoc' ON OFF) \
    -D protobuf_BUILD_SHARED_LIBS="yes" \
    -D protobuf_BUILD_TESTS=$(usex 'test' ON OFF) \
    -D protobuf_DISABLE_RTTI="no" \
    -D protobuf_INSTALL="yes" \
    -D protobuf_TEST_XML_OUTDIR=$(usex 'test' ON OFF) \
    -D protobuf_WITH_ZLIB=$(usex 'zlib' ON OFF) \
    -D protobuf_VERBOSE=$(usex 'debug' ON OFF) \
    -D CMAKE_MODULE_PATH="${BUILD_DIR}/cmake" \
    -D protobuf_LOCAL_DEPENDENCIES_ONLY="yes" \
    -D BUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  ninja -j "$(nproc)" -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${ED}" cmake --install build $(usex 'strip' --strip) || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  find "$(get_libdir)/" -name "*.la" -delete || die

  #test -d "usr/bin" && mv -v -n usr/bin -t .

  # fix: cmake wrong the pkgconfig
  grep '${prefix}' < $(get_libdir)/pkgconfig/${PN}.pc
  sed -e 's|${prefix}||' -i $(get_libdir)/pkgconfig/*${PN}*.pc

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  if use 'protoc'; then
    use 'stest' && { bin/${PROG} --version || : die "binary work... error";}
    ldd "bin/${PROG}" || { use 'static' && true || : die "library deps work... error";}
  else
    ldd "$(get_libdir)"/lib*${PN}*.so || : die "library deps work... error"
  fi

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz