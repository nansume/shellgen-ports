#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-05-23 10:00 UTC - last change
# Build with useflag: +static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-build/cmake/cmake-4.0.2-r1.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX _PKG_CONFIG _PKG_CONFIG_LIBDIR _PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="Cross platform Make"
HOMEPAGE="https://cmake.org/"
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
PN=${PN%[0-9]}
PV="3.22.2"
PV="4.0.2"
SRC_URI="https://cmake.org/files/v${PV%.*}/${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-ssl -doc -emacs -ncurses -qt5 -test -rpath +static -static-libs -shared (+musl) +stest +strip"
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
#PKG_CONFIG="pkgconf"
#PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
#PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
CMAKE_PREFIX_PATH="/${LIB_DIR}/cmake"
PROG=${PN}
IONICE_COMM='nice -n 19'

if test "X${USER}" != 'Xroot'; then
  mksrc-prepare
elif test "${BUILD_CHROOT:=0}" -eq '0'; then
  PATH="${PATH:+${PATH}:}${PDIR}/misc.d:${PDIR}/etools.d"
elif test "${BUILD_CHROOT:=0}" -ne '0'; then
  PATH="$(xpath):${PDIR%/}/misc.d:${PDIR%/}/etools.d"
  printf %s\\n "PATH='${PATH}'" "PDIR='${PDIR}'"
fi

. "${PDIR%/}/etools.d/"build-functions

printf %s\\n "BUILDLIST='${BUILDLIST}'" "PV='${PV}'" "PKGNAME='${PKGNAME}'"

chroot-build || die "Failed chroot... error"

pkginst \
  "dev-build/cmake" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'ssl' && pkginst "dev-libs/libressl-compat"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then

  cd "${DISTSOURCE}/" || die "distsource dir: not found... error"

  gunzip -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "gunzip -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  if use 'openssl'; then
    IUSE="${IUSE} +ssl"
  elif use '!ssl'; then
    IUSE="${IUSE} -ssl"
  fi

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use !shared && use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
    append-ldflags "-s -static --static"
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install/strip"

  printf %s\\n "CC='${CC}'" "CXX='${CXX}'" "CPP='${CPP}'" "LIBTOOL='${LIBTOOL}'" "CFLAGS='${CFLAGS}'"
  printf %s\\n "CPPFLAGS='${CPPFLAGS}'" "CXXFLAGS='${CXXFLAGS}'" "FCFLAGS='${FCFLAGS}'" "FFLAGS='${FFLAGS}'"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  . runverb \
  ./configure \
    CC="${CC}" \
    CXX="${CXX}" \
    --parallel="$(nproc)" \
    -- \
    -D CMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -D CMAKE_BIN_DIR="${EPREFIX%/}/bin" \
    -D CMAKE_DATA_DIR="${DPREFIX}/share" \
    -D CMAKE_DOC_DIR="${DPREFIX}/share/doc/${PN}-${PV}" \
    -D CMAKE_XDGDATA_DIR="${DPREFIX}/share" \
    -D CMAKE_BUILD_TYPE="MinSizeRel" \
    -D CMAKE_USE_OPENSSL=$(usex 'ssl' ON OFF) \
    -D BUILD_CursesDialog=$(usex 'ncurses' ON OFF) \
    -D BUILD_QtDialog=$(usex 'qt5' ON OFF) \
    -D CMAKE_SKIP_RPATH=$(usex !rpath ON OFF) \
    -D BUILD_TESTING=$(usex 'test' ON OFF) \
    -D STATIC_ONLY=$(usex 'static' ON OFF) \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"
  printf %s\\n "make DESTDIR=${ED} ${INSTALL_OPTS}"

  cd "${ED}/" || die "install dir: not found... error"

  rm -r -- "usr/share/doc/" "usr/share/Help/" "usr/share/bash-completion/"

  # simple test
  use 'static' && LD_LIBRARY_PATH=
  bin/${PN} --version || die "binary work... error"

  ldd "bin/${PN}" || { use 'static' && true;}

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz