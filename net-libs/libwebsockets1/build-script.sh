#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-03-01 12:00 UTC - last change
# Build with useflag: -static +static-libs +shared +mbedtls -lfs +nopie -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-libs/libwebsockets/libwebsockets-4.3.5.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="A flexible pure-C library for implementing network protocols"
HOMEPAGE="https://libwebsockets.org/"
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
PN=${PN%[0-9]}
PV="4.3.3"
SRC_URI="https://github.com/warmcat/libwebsockets/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+access-log -caps +cgi +client -dbus +extensions +generic-sessions -http-proxy"
IUSE="${IUSE} -http2 +ipv6 +lejp -libev -libevent +libuv +mbedtls +peer-limits"
IUSE="${IUSE} +server-status +smtp -socks5 +sqlite3 +ssl +threads +zip"
IUSE="${IUSE} +static-libs +shared -doc (+musl) +stest +strip"
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
SYMVER="19"

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
  "dev-lang/perl  # optional?" \
  "#dev-libs/gmp  # for openssl (optional)" \
  "dev-libs/libuv" \
  "#dev-libs/openssl3" \
  "dev-util/cmake" \
  "dev-util/pkgconf" \
  "net-libs/mbedtls  # required: mbedtls[static-libs,shared]" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl0" \
  "sys-libs/zlib  # for pkg,openssl" \
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
    use 'static' && append-ldflags "-s -static --static"
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  cmake -B build -G "Unix Makefiles" \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}/usr" \
    -DLWS_INSTALL_LIB_DIR="${EPREFIX%/}/$(get_libdir)" \
    -DLWS_INSTALL_CMAKE_DIR=${CMAKE_PREFIX_PATH}/${PN} \
    -DLWS_INSTALL_INCLUDE_DIR="${INCDIR}" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON \
    -DDISABLE_WERROR=ON \
    -DLWS_BUILD_HASH=unknown \
    -DLWS_HAVE_LIBCAP=$(usex 'caps') \
    -DLWS_IPV6=$(usex 'ipv6') \
    -DLWS_ROLE_DBUS=$(usex 'dbus') \
    -DLWS_WITHOUT_CLIENT=$(usex !client) \
    -DLWS_WITHOUT_TEST_CLIENT=ON \
    -DLWS_WITH_ACCESS_LOG=$(usex 'access-log') \
    -DLWS_WITH_CGI=$(usex 'cgi') \
    -DLWS_WITH_GENERIC_SESSIONS=$(usex 'generic-sessions') \
    -DLWS_WITH_HTTP2=$(usex 'http2') \
    -DLWS_WITH_HTTP_PROXY=$(usex 'http-proxy') \
    -DLWS_WITH_HUBBUB=$(usex 'http-proxy') \
    -DLWS_WITH_LEJP=$(usex 'lejp') \
    -DLWS_WITH_LIBEV=$(usex 'libev') \
    -DLWS_WITH_LIBEVENT=$(usex 'libevent') \
    -DLWS_WITH_LIBUV=$(usex 'libuv') \
    -DLWS_WITH_MBEDTLS=$(usex 'mbedtls') \
    -DLWS_WITH_PEER_LIMITS=$(usex 'peer-limits') \
    -DLWS_WITH_SERVER_STATUS=$(usex 'server-status') \
    -DLWS_WITH_SMTP=$(usex 'smtp') \
    -DLWS_WITH_SOCKS5=$(usex 'socks5') \
    -DLWS_WITH_SQLITE3=$(usex 'sqlite3') \
    -DLWS_WITH_SSL=$(usex 'ssl') \
    -DLWS_WITH_STATIC=$(usex 'static-libs' ON OFF) \
    -DLWS_WITH_SHARED=$(usex 'shared' ON OFF) \
    -DLWS_WITH_STRUCT_JSON=$(usex 'lejp') \
    -DLWS_WITH_THREADPOOL=$(usex 'threads') \
    -DLWS_WITH_ZIP_FOPS=$(usex 'zip') \
    -DLWS_WITHOUT_EXTENSIONS=$(usex !extensions) \
    -DLWS_WITHOUT_TESTAPPS=ON \
    -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  DESTDIR="${ED}" cmake --build build --target ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  test -d "usr/lib/pkgconfig" && mv -v -n usr/lib/pkgconfig -t "$(get_libdir)/"
  test -d "usr/lib" && rm -r -- "usr/lib/"

  # fix: cmake wrong the pkgconfig
  grep "^prefix=.*" < $(get_libdir)/pkgconfig/${PN}.pc
  #cat $(get_libdir)/pkgconfig/${PN}*.pc
  sed \
    -e "1s|^prefix=.*|prefix=|;t" \
    -e "3s|^libdir=.*|libdir=/$(get_libdir)|;t" \
    -e "4s|^includedir=.*|includedir=/usr/include|;t" \
    -i $(get_libdir)/pkgconfig/${PN}*.pc || : die

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  ldd "$(get_libdir)/${PN}.so.${SYMVER}" || { use 'static' && true || : die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz