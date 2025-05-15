#!/bin/sh
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-12-21 18:00 UTC - last change

export USER XPN PF PV WORKDIR PKGNAME DPREFIX BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR S SDIR
export CMAKE_PREFIX_PATH

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:=$PWD}
XPN=${PN}
PKG_DIR='/pkg'
LC_ALL='C'
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PV="3.22.2"
DESCRIPTION="Cross platform Make"
HOMEPAGE="https://cmake.org/"
SRC_URI="ftp://mirrors.tera-byte.com/pub/gentoo/distfiles/${PN}-${PV}.tar.gz"
LICENSE="BSD"
USER=${USER:-root}
USE_BUILD_ROOT='0'
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX='/usr'
INCDIR="${DPREFIX}/include"
INSTALL_OPTS='install'
HOSTNAME=$(hostname)
BUILD_USER='tools'
SRC_DIR='build'
IONICE_COMM='nice -n 19'
ZCOMP='gunzip'
IUSE="-rpath +static -patch (-musl) -ssl -doc -emacs -ncurses -qt5 -test +strip"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
DPREFIX="/usr"
XPWD=${5:-$XPWD}
P="${P:-${XPWD##*/}}"
SN=${P}
CATEGORY=${11:-$CATEGORY}
PN="${PN:-${P%%_*}}"
PN=${12:-$PN}
PORTS_DIR=${PWD%/$P}
DISTDIR="/usr/distfiles"
DISTSOURCE="${PDIR%/}/sources"
FILESDIR=${DISTSOURCE}
INSTALL_DIR="${PDIR%/}/install"
S="${PDIR%/}/${SRC_DIR}"
SDIR="${S}"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
#PV=$(pkgver)
PKGNAME=$(pkgname)
ZCOMP=$(zcomp-as "${PF}")
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
#PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
#PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:${DPREFIX}/share/pkgconfig"
BUILDLIST=${10:-$BUILDLIST}
ABI_BUILD="${ABI_BUILD:-${1:?}}"
CMAKE_PREFIX_PATH="/${LIB_DIR}/cmake"

if test "X${USER}" != 'Xroot'; then
  XPWD=${5:?}
  XPN=${6:?}
  BUILD_CHROOT=${7:?}
  USE_BUILD_ROOT=${9}
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
  "dev-util/cmake" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-kernel/linux-headers" \
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

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  use 'strip' && INSTALL_OPTS='install/strip'

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
  if use 'static'; then
    append-flags -Os
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  printf %s\\n "CC='${CC}'" "CXX='${CXX}'" "CPP='${CPP}'" "LIBTOOL='${LIBTOOL}'" "CFLAGS='${CFLAGS}'"
  printf %s\\n "CPPFLAGS='${CPPFLAGS}'" "CXXFLAGS='${CXXFLAGS}'" "FCFLAGS='${FCFLAGS}'" "FFLAGS='${FFLAGS}'"

  IFS=${NL}

  . runverb \
  ./configure \
    CC="gcc$(use static && printf ' -static --static')" \
    CXX="g++$(use static && printf ' -static --static')" \
    $(use 'static' && printf "LDFLAGS=-s -static --static") \
    --parallel="$(cpun)" \
    -- \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -DCMAKE_BIN_DIR="${EPREFIX%/}/bin" \
    -DCMAKE_DATA_DIR="${DPREFIX}/share" \
    -DCMAKE_DOC_DIR="${DPREFIX}/share/doc/${PN}" \
    -DCMAKE_XDGDATA_DIR="${DPREFIX}/share" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DCMAKE_USE_OPENSSL=$(usex ssl) \
    -DBUILD_CursesDialog=$(usex ncurses) \
    -DBUILD_QtDialog=$(usex qt5) \
    -DCMAKE_SKIP_RPATH=$(usex !rpath) \
    -DBUILD_TESTING=$(usex test) \
    -DSTATIC_ONLY=$(usex static) \
    -Wno-dev || die "configure... error"

  make -j "$(cpun)" || die "Failed make build"

  make DESTDIR="${INSTALL_DIR}" ${INSTALL_OPTS} || die "make install... error"
  printf %s\\n "make DESTDIR=${INSTALL_DIR} ${INSTALL_OPTS}"

  cd "${INSTALL_DIR}/" || die "install dir: not found... error"

  rm -r -- "usr/share/doc/" "usr/share/Help/" "usr/share/bash-completion/"

  # simple test
  use 'static' && LD_LIBRARY_PATH=
  bin/${PN} --version || die "binary work... error"

  ldd "bin/${PN}" || { use 'static' && true;}

  exit 0
fi

cd "${INSTALL_DIR}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
