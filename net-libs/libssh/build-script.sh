#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Description: Access a working SSH implementation by means of a library
# Homepage: https://www.libssh.org
# License: LGPL-2.1
# Depends: <deps>
# Date: 2026-02-02 21:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-libs/libssh/libssh-0.11.3.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="0.11.3"
SRC_URI="https://www.libssh.org/files/${PV%.*}/${PN}-${PV}.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
inst="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-debug -doc -examples -gssapi +mbedtls -pcap +server +sftp +static-libs -test +zlib"
IUSE="${IUSE} +shared (+musl) +stest +strip"
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
  "dev-build/cmake3" \
  "dev-util/pkgconf" \
  "net-libs/mbedtls3" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/make" \
  "sys-libs/argp-standalone  # fix for musl" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
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
  append-flags -O2 -DNDEBUG -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && inst="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  sed -e "/^check_include_file.*HAVE_VALGRIND_VALGRIND_H/s/^/#DONT /" -i ConfigureChecks.cmake || die

  mbedtls_include=$(${PKG_CONFIG} mbedtls --cflags-only-I)
  mbedtls_include=${mbedtls_include#??}
  printf %s\\n "mbedtls_include='${mbedtls_include}'"

  cmake -B build -G "Unix Makefiles" \
    -D CMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -D CMAKE_INSTALL_BINDIR="bin" \
    -D CMAKE_INSTALL_LIBDIR="$(get_libdir)" \
    -D CMAKE_INSTALL_INCLUDEDIR="${INCDIR#/}" \
    -D CMAKE_INSTALL_DATAROOTDIR="${DPREFIX#/}/share" \
    -D CMAKE_INSTALL_DOCDIR="${DPREFIX#/}/share/doc" \
    -D CMAKE_BUILD_TYPE="None" \
    -D WITH_NACL=OFF \
    -D WITH_STACK_PROTECTOR=OFF \
    -D WITH_STACK_PROTECTOR_STRONG=OFF \
    -D WITH_DEBUG_CALLTRACE=$(usex 'debug') \
    -D WITH_DEBUG_CRYPTO=$(usex 'debug') \
    -D WITH_GCRYPT=OFF \
    -D WITH_GSSAPI=$(usex 'gssapi') \
    -D WITH_MBEDTLS=$(usex 'mbedtls') \
    -D MBEDTLS_FOUND=$(usex 'mbedtls') \
    -D MBEDTLS_INCLUDE_DIR="${mbedtls_include}" \
    -D WITH_PCAP=$(usex 'pcap') \
    -D WITH_SERVER=$(usex 'server') \
    -D WITH_SFTP=$(usex 'sftp') \
    -D BUILD_STATIC_LIB=$(usex 'static-libs') \
    -D UNIT_TESTING=$(usex 'test') \
    -D WITH_ZLIB=$(usex 'zlib') \
    -D CMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON \
    -D BUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -W no-dev \
    || die "Failed cmake build"

  DESTDIR="${ED}" cmake --build build --target ${inst} -j "$(nproc)" || die "make install... error"

  use 'static-libs' && mv -n -v build/src/${PN}.a -t "${ED}"/"$(get_libdir)"/

  cd "${ED}/" || die "install dir: not found... error"

  #strip-lto-bytecode

  # fix: cmake wrong the pkgconfig
  grep '${prefix}' < $(get_libdir)/pkgconfig/${PN}.pc
  sed -e 's|${prefix}||' -i $(get_libdir)/pkgconfig/${PN}.pc

  use 'static-libs' && strip --strip-unneeded "$(get_libdir)/"${PN}.a

  ldd "$(get_libdir)/"${PN}.so || { use 'static' && true || : die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz