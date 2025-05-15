#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-13 12:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="A C++ implementation of Phil Zimmermann's ZRTP specification"
HOMEPAGE="https://github.com/wernerd/ZRTPCPP"
LICENSE="GPL-3"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
MY_PN="ZRTPCPP"
PV="4.7.0"  # no-build
PV="4.6.6"
SRC_URI="
  https://github.com/wernerd/${PN}/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz  # Ver: 4.7.0
  http://data.gpo.zugaina.org/nest/dev-libs/${PN}/files/${PN}-4.7.0-wrapper.patch
  http://data.gpo.zugaina.org/nest/dev-libs/${PN}/files/${PN}-4.7.0-CMakeLists.patch
"
SRC_URI="https://github.com/wernerd/${PN}/archive/V${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-axo +ccrtp -core +empty -sdes -sqlite -sqlcipher -tivi -static-libs +shared -doc (+musl) +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${MY_PN}-${PV}"
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
  "dev-cpp/commoncpp2  # deps ccrtp" \
  "dev-libs/ccrtp" \
  "dev-libs/gmp  # deps gnutls" \
  "dev-libs/libgcrypt  # deps gnutls" \
  "dev-libs/libgpg-error  # deps gnutls" \
  "dev-libs/libtasn1  # deps gnutls" \
  "dev-libs/libunistring  # deps gnutls" \
  "dev-libs/nettle  # deps gnutls" \
  "dev-libs/ucommon  # deps ccrtp" \
  "dev-util/cmake" \
  "dev-util/pkgconf" \
  "net-libs/gnutls  # deps commoncpp2" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps gnutls" \
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

  use 'strip' && INSTALL_OPTS="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # Ver: 4.7.0
  #patch -p1 -E < ${FILESDIR}/${PN}-${PV}"-wrapper.patch
  #patch -p1 -E < ${FILESDIR}/${PN}-${PV}"-CMakeLists.patch

  use 'x32' && sed "s/lib64/$(get_libdir)/g" -i CMakeLists.txt

  mkdir -pm 0755 -- "${BUILD_DIR}/build/"
  cd "${BUILD_DIR}/build/" || die "builddir: not found... error"

  . runverb \
  cmake \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DAXO="$(usex axo)" \
    -DCCRTP="$(usex ccrtp)" \
    -DCORE_LIB="$(usex core)" \
    -DNO_CACHE="$(usex empty)" \
    -DSDES="$(usex sdes)" \
    -DSQLCIPHER="$(usex sqlcipher)" \
    -DSQLITE="$(usex sqlite)" \
    -DTIVI="$(usex tivi)" \
    -DBUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -DCMAKE_SKIP_RPATH="ON" \
    -DCMAKE_SKIP_INSTALL_RPATH="ON" \
    -Wno-dev \
    .. || die "Failed cmake build"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  mkdir -m 0755 -- "usr/"
  mv -vn include -t "usr/"

  # fix: cmake wrong the pkgconfig
  sed \
    -e "4s|^includedir=.*|includedir=/usr/include|;t" \
    -i ${ED}/$(get_libdir)/pkgconfig/lib${PN}.pc || die

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
