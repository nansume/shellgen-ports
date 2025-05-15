#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2024-10-29 13:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="C client library for MariaDB/MySQL"
HOMEPAGE="https://mariadb.org/"
LICENSE="LGPL-2.1"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="3.3.8"
SRC_URI="http://data.gpo.zugaina.org/gentoo/dev-db/mariadb-connector-c"
SRC_URI="
  https://downloads.mariadb.com/Connectors/c/connector-c-${PV}/${PN}-${PV}-src.tar.gz
  ${SRC_URI}/files/mariadb-connector-c-3.1.3-fix-pkconfig-file.patch
  ${SRC_URI}/files/mariadb-connector-c-3.3.4-remove-zstd.patch
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
IUSE="-curl -gnutls -kerberos -ssl -static-libs -test +shared -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}-src"
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
  "dev-util/cmake" \
  "dev-util/pkgconf" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "#sys-libs/zlib  # it bundled, no needed" \
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

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"
  patch -p1 -E < "${FILESDIR}"/${PN}-3.1.3-fix-pkconfig-file.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-3.3.4-remove-zstd.patch

  sed -e '/SET(WARNING_AS_ERROR "-Werror")/d' -i CMakeLists.txt || die

  # These tests the remote_io plugin which requires network access
  sed 's/{"test_remote1", test_remote1, TEST_CONNECTION_NEW, 0, NULL, NULL},//g' \
    -i "unittest/libmariadb/misc.c" || die

  # These tests don't work with --skip-grant-tables
  sed 's/{"test_conc366", test_conc366, TEST_CONNECTION_DEFAULT, 0, NULL, NULL},//g' \
    -i "unittest/libmariadb/connection.c"
  sed 's/{"test_conc66", test_conc66, TEST_CONNECTION_DEFAULT, 0, NULL,  NULL},//g' \
    -i "unittest/libmariadb/connection.c"

  # [Warning] Aborted connection 2078 to db: 'test' user: 'root' host: '' (Got an error reading communication packets)
  # Not sure about this one - might also require network access
  sed 's/{"test_default_auth", test_default_auth, TEST_CONNECTION_NONE, 0, NULL, NULL},//g' \
    -i "unittest/libmariadb/connection.c" || die

  mkdir -m 0755 -- "${BUILD_DIR}/build/"
  cd "${BUILD_DIR}/build/" || die "builddir: not found... error"

  . runverb \
  cmake \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}/" \
    -DINSTALL_BINDIR="${EPREFIX%/}/bin" \
    -DINSTALL_LIBDIR="${EPREFIX%/}/$(get_libdir)" \
    -DINSTALL_PCDIR="$(get_libdir)/pkgconfig" \
    -DINSTALL_PLUGINDIR="$(get_libdir)/mariadb/plugin" \
    -DINSTALL_INCLUDEDIR="${INCDIR}" \
    -DINSTALL_DATAROOTDIR="${DPREFIX}/share" \
    -DINSTALL_MANDIR="${DPREFIX}/share/man" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DWITH_EXTERNAL_ZLIB="OFF" \
    -DWITH_SSL:STRING=$(usex 'ssl' $(usex gnutls GNUTLS OPENSSL) OFF) \
    -DWITH_CURL=$(usex 'curl') \
    -DWITH_ICONV="ON" \
    -DCLIENT_PLUGIN_AUTH_GSSAPI_CLIENT:STRING=$(usex kerberos DYNAMIC OFF) \
    -DMARIADB_UNIX_ADDR="${EPREFIX}/var/run/mysqld/mysqld.sock" \
    -DWITH_UNIT_TESTS=$(usex 'test') \
    -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -DCMAKE_SKIP_INSTALL_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    .. || die "Failed cmake build"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  if ! use 'static-libs'; then
    find "$(get_libdir)/" -name "*.a" -delete || die
  fi

  # fix: cmake wrong the pkgconfig
  grep "^prefix=.*" < $(get_libdir)/pkgconfig/libmariadb.pc &&
  sed \
    -e "s|^prefix=.*|prefix=|" \
    -e "s|^includedir=.*|includedir=/usr/include|" \
    -e "s|^libdir=.*|libdir=/$(get_libdir)|" \
    -i $(get_libdir)/pkgconfig/libmariadb.pc || : die

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
