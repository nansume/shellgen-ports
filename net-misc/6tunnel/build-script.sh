#!/bin/sh
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-12-19 10:00 UTC - last change

#inherit pkg-export build-functions
export USER XPN PF PV WORKDIR PKGNAME DPREFIX BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI PATH
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR S SDIR

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:-$PWD}
XPN=${PN}
PKG_DIR='/pkg'
LC_ALL='C'
PV="0.13"
DESCRIPTION="TCP proxy for applications that don't speak IPv6"
HOMEPAGE="http://toxygen.net/6tunnel"
SRC_URI="https://github.com/wojtekka/${PN}/archive/refs/tags/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
LICENSE="GPL-2"
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
IUSE="+static +diet (-musl) +strip"
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
PKGNAME=$(pkgname)
ZCOMP=$(zcomp-as "${PF}")
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}

if test "X${USER}" != 'Xroot'; then
  ABI_BUILD=${1:?} LIBDIR=${2:?} LIB_DIR=${3:?} PDIR=${4:?} XPWD=${5:?} XPN=${6:?}
  BUILD_CHROOT=${7:?} USE_BUILD_ROOT=${9} BUILDLIST=${10} CATEGORY=${11:?} PN=${12:?}
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
  "dev-lang/perl" \
  "sys-devel/autoconf" \
  "sys-devel/automake" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/m4" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'diet' && pkginst "dev-libs/dietlibc"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then

  cd "${DISTSOURCE}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 ;;
    'x86')   append-flags -m32  ;;
    'amd64') append-flags -m64  ;;
  esac
  append-flags -Os -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  use 'strip' && INSTALL_OPTS='install-strip'
  use 'diet' && PATH="${PATH:+${PATH}:}/opt/diet/bin"

	IFS=${NL}

  autoreconf --install

  . runverb \
  ./configure \
    CC="$(use diet && printf 'diet -Os gcc -nostdinc' || printf gcc)" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    DIET="" || die "configure... error"

  make -j "$(cpun)" || die "Failed make build"

  . runverb \
  make DESTDIR="${INSTALL_DIR}" ${INSTALL_OPTS} || die "make install... error"

  cd "${INSTALL_DIR}/" || die "install dir: not found... error"

  rm -r -- "usr/"

  LD_LIBRARY_PATH= bin/${PN} -v

  exit 0
fi

cd "${INSTALL_DIR}/" || die "install dir: not found... error"

ldd "bin/${PN}" || { use 'static' && true;}

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
