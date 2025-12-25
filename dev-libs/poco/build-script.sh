#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-12-21 14:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-libs/poco/poco-1.14.2.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="C++ libraries for building network-based applications"
HOMEPAGE="https://pocoproject.org/"
LICENSE="Boost-1.0"
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="1.14.2"
SRC_URI="https://github.com/pocoproject/${PN}/archive/${PN}-${PV}-release.tar.gz -> ${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
inst="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-7z -activerecord -avahi -cppparser -crypt +data -examples -file2pagecompiler -iodbc -mariadb -mongodb"
IUSE="${IUSE} -mysql +net -odbc -pagecompiler -pdf -pocodoc -postgres -prometheus -sqlite -test +util +xml +zip"
IUSE="${IUSE} -static-libs +shared -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PN}-${PV}-release"
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
PROG=${PN}

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
  "dev-build/cmake3  # cmake4" \
  "#dev-db/libiodbc  # odbc,iodbc" \
  "#dev-db/mariadb-connector-c  # mariadb" \
  "#dev-db/mysql-connector-c  # mysql" \
  "#dev-db/postgresql  # postgres" \
  "#dev-db/sqlite3  # sqlite" \
  "#dev-db/unixodbc  # odbc,!iodbc,!libiodbc" \
  "dev-libs/expat  # xml" \
  "dev-libs/libutf8proc" \
  "dev-libs/pcre2" \
  "#dev-libs/openssl3  # crypt" \
  "dev-util/pkgconf" \
  "#media-libs/libpng  # pdf" \
  "#net-dns/avahi  # avahi" \
  "sys-devel/binutils  # binutils6" \
  "sys-devel/gcc14  # gcc6" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib  # zip" \
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

  use 'strip' && inst="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  cmake -B build -G "Unix Makefiles" \
    -D CMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -D CMAKE_INSTALL_BINDIR="bin" \
    -D CMAKE_INSTALL_LIBDIR="$(get_libdir)" \
    -D CMAKE_INSTALL_INCLUDEDIR="${INCDIR#/}" \
    -D CMAKE_INSTALL_DATAROOTDIR="${DPREFIX#/}/share" \
    -D CMAKE_INSTALL_DOCDIR="${DPREFIX#/}/share/doc" \
    -D CMAKE_BUILD_TYPE="Release" \
    -D POCO_UNBUNDLED=ON \
    -D ENABLE_APACHECONNECTOR=OFF \
    -D ENABLE_ACTIVERECORD=$(usex 'activerecord' ON OFF) \
    -D ENABLE_ACTIVERECORD_COMPILER=$(usex 'activerecord' ON OFF) \
    -D ENABLE_CPPPARSER=$(usex 'cppparser' ON OFF) \
    -D ENABLE_CRYPTO=$(usex 'crypt' ON OFF) \
    -D ENABLE_DATA=$(usex 'data' ON OFF) \
    -D ENABLE_DATA_MYSQL=$(usex 'mysql' ON OFF) \
    -D ENABLE_DATA_ODBC=$(usex 'odbc' ON OFF) \
    -D ENABLE_DATA_POSTGRESQL=$(usex 'postgres' ON OFF) \
    -D ENABLE_DATA_SQLITE=$(usex 'sqlite' ON OFF) \
    -D ENABLE_DNSSD=$(usex 'avahi' ON OFF) \
    -D ENABLE_DNSSD_AVAHI=$(usex 'avahi' ON OFF) \
    -D ENABLE_JSON=$(usex 'util' ON OFF) \
    -D ENABLE_JWT=$(usex 'crypt' ON OFF) \
    -D ENABLE_MONGODB=$(usex 'mongodb' ON OFF) \
    -D ENABLE_NET=$(usex 'net' ON OFF) \
    -D ENABLE_NETSSL=$(usex 'crypt' ON OFF) \
    -D ENABLE_NETSSL_WIN=OFF \
    -D ENABLE_PAGECOMPILER=$(usex 'pagecompiler' ON OFF) \
    -D ENABLE_PAGECOMPILER_FILE2PAGE=$(usex 'file2pagecompiler' ON OFF) \
    -D ENABLE_PDF=$(usex 'pdf' ON OFF) \
    -D ENABLE_POCODOC=$(usex 'pocodoc' ON OFF) \
    -D ENABLE_PROMETHEUS=$(usex 'prometheus' ON OFF) \
    -D ENABLE_SEVENZIP=$(usex '7z' ON OFF) \
    -D ENABLE_TESTS=$(usex 'test' ON OFF) \
    -D ENABLE_UTIL=$(usex 'util' ON OFF) \
    -D ENABLE_XML=$(usex 'xml' ON OFF) \
    -D ENABLE_ZIP=$(usex 'zip' ON OFF) \
    -D UTF8PROC_INCLUDE_DIR="/usr/include/libutf8proc" \
    -D BUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  DESTDIR="${ED}" cmake --build build --target ${inst} -j "$(nproc)" || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  mkdir -pm 0755 -- usr/
  mv -n include -t usr/

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz