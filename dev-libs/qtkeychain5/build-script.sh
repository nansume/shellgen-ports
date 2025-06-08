#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-06-07 12:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# https://crux.nu/ports/crux-3.8/contrib/qtkeychain/Pkgfile

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="QtKeychain is a QT API to store passwords and other secret data securely"
HOMEPAGE="https://github.com/frankosterfeld/qtkeychain"
LICENSE="BSD-2"
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
PV="0.15.0"
SRC_URI="https://github.com/frankosterfeld/${PN}/archive/${PV}/${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-keyring +qt5 -qt6 -test -static-libs +shared (+musl) +stest +strip"
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
  "app-crypt/libsecret" \
  "#app-text/doxygen1" \
  "dev-build/cmake3" \
  "#dev-db/sqlite3  # deps bzrtp" \
  "#dev-libs/expat  # deps python3" \
  "dev-libs/glib74  # deps qt5" \
  "dev-libs/gmp  # deps libsrtp" \
  "dev-libs/jsoncpp" \
  "dev-libs/icu76  # deps qt5base" \
  "#dev-libs/libffi  # deps python3,qt5" \
  "dev-libs/libxml2-1  # deps bzrtp" \
  "dev-libs/pcre2  # for glib74" \
  "dev-libs/openssl3  # deps libsrtp" \
  "dev-libs/xerces-c" \
  "dev-qt/qt5base15  # required: qt-5.13" \
  "dev-qt/qt5declarative15  # extensions?" \
  "dev-qt/qt5tools15" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib  # alsa" \
  "media-libs/freetype  # deps qt5" \
  "media-libs/fontconfig  # deps qt5" \
  "media-libs/libjpeg-turbo3  # jpeg" \
  "media-libs/mesa  # deps qt5" \
  "sys-apps/dbus" \
  "sys-devel/binutils" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps libsrtp,soci" \
  "x11-base/xorg-proto  # deps qt5" \
  "x11-libs/libdrm  # deps qt5" \
  "x11-libs/libice  # deps qt5" \
  "x11-libs/libpciaccess  # deps qt5" \
  "x11-libs/libsm  # deps qt5" \
  "x11-libs/libvdpau  # deps qt5" \
  "x11-libs/libx11  # deps qt5" \
  "x11-libs/libxau  # deps qt5" \
  "x11-libs/libxcb  # deps qt5" \
  "x11-libs/libxcursor  # deps qt5" \
  "x11-libs/libxdamage  # deps qt5" \
  "x11-libs/libxdmcp  # deps qt5" \
  "x11-libs/libxext  # deps qt5" \
  "x11-libs/libxfixes  # deps qt5" \
  "x11-libs/libxft  # deps qt5" \
  "x11-libs/libxi  # deps qt5" \
  "x11-libs/libxrandr  # deps qt5" \
  "x11-libs/libxrender  # deps qt5" \
  "x11-libs/libxv  # deps qt5" \
  "x11-libs/libxt  # dbus" \
  "x11-libs/libxshmfence  # deps qt5" \
  "x11-libs/libxxf86vm  # deps qt5" \
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
    -D CMAKE_INSTALL_PREFIX="${EPREFIX%/}/usr" \
    -D CMAKE_INSTALL_BINDIR="${EPREFIX%/}/bin" \
    -D CMAKE_INSTALL_LIBDIR="${EPREFIX%/}/$(get_libdir)" \
    -D CMAKE_INSTALL_INCLUDEDIR="${INCDIR}" \
    -D CMAKE_INSTALL_LIBEXECDIR=lib/$name \
    -D CMAKE_INSTALL_LIBEXECDIR="${DPREFIX}/libexec" \
    -D CMAKE_INSTALL_DATAROOTDIR="${DPREFIX}/share" \
    -D CMAKE_INSTALL_DATADIR="share" \
    -D CMAKE_BUILD_TYPE="Release" \
    -D CMAKE_CXX_FLAGS_RELEASE="${CXXFLAGS}" \
    -D CMAKE_C_FLAGS_RELEASE="${CFLAGS}" \
    -D ECM_MKSPECS_INSTALL_DIR="${EPREFIX%/}"/$(get_libdir)/$(usex 'qt5' qt5 qt6)/mkspecs \
    -D BUILD_WITH_QT6=OFF \
    -D BUILD_WITH_QT5=ON \
    -D BUILD_TRANSLATIONS=ON \
    -D LIBSECRET_SUPPORT=$(usex 'keyring' ON OFF) \
    -D BUILD_TEST_APPLICATION=OFF \
    -D BUILD_TESTING=$(usex 'test' ON OFF) \
    -D BUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  DESTDIR="${ED}" cmake --build build --target ${INSTALL_OPTS} -j "$(nproc)" || : die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  ldd "$(get_libdir)"/libqt5keychain.so.${PV} || : die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz