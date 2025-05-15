#!/bin/sh
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-12-14 10:00 UTC - last change

NL="$(printf '\n\t')"; NL=${NL%?} XPWD=${XPWD:=$PWD} XPN=${PN} PKG_DIR='/pkg' LC_ALL='C'

PV="1.2.1"
DESCRIPTION="A library for multiprecision complex arithmetic with exact rounding"
HOMEPAGE="https://www.multiprecision.org/mpc/ https://gitlab.inria.fr/mpc/mpc"

SRC_URI="
  ftp://ftp.gnu.org/gnu/${PN}/${PN}-${PV}.tar.gz
  #http://musl.cc/x86_64-linux-muslx32-native.tgz
"

LICENSE="LGPL-3+ FDL-1.3+"

USER=${USER:-root}
USE_BUILD_ROOT='0'
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=${PWD}
DPREFIX='/usr'
INCDIR="${DPREFIX}/include"
INSTALL_OPTS='install'
HOSTNAME=$(hostname)
BUILD_USER='tools'
SRC_DIR='build'
IONICE_COMM='nice -n 19'
ZCOMP='gunzip'
IUSE="-bootstrap +static-libs +shared +strip"

export BUILD_CHROOT
export USER XPN PF PV WORKDIR PKGNAME DPREFIX
export LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI

if test "X${USER}" != 'Xroot'; then
  ABI_BUILD=${1:?} LIBDIR=${2:?} LIB_DIR=${3:?} PDIR=${4:?} XPWD=${5:?} XPN=${6:?}
  BUILD_CHROOT=${7:?} USE_BUILD_ROOT=${9} BUILDLIST=${10} CATEGORY=${11:?} PN=${12:?}
  PWD=${PWD%/}
  mksrc-prepare
elif test "${BUILD_CHROOT:=0}" -eq '0'; then
  PATH="${PATH:+${PATH}:}${PDIR}/misc.d:${PDIR}/etools.d"
elif test "${BUILD_CHROOT:=0}" -ne '0'; then
  PATH="$(xpath):${PDIR%/}/misc.d:${PDIR%/}/etools.d"
  printf %s\\n "PATH='${PATH}'" "PDIR='${PDIR}'"
fi

XABI=${ABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
DPREFIX="/usr"
PDIR=${PWD}
P=${XPWD##*/}
SN=${P}
PN=${P%%_*}
PORTS_DIR=${PWD%/$P}
DISTSOURCE="/sources"
FILESDIR=${DISTSOURCE}
INSTALL_DIR="${PORTS_DIR}/${P}/install"
S="${PORTS_DIR}/${P}/${SRC_DIR}"
SDIR="${PORTS_DIR}/${P}/${SRC_DIR}"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
PKGNAME=$(pkgname)
ZCOMP=$(zcomp-as "${PF}")

export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTSOURCE FILESDIR INSTALL_DIR S SDIR

chroot-build || exit

. "${PDIR%/}/etools.d/"pre-env-chroot
. "${PDIR%/}/etools.d/"build-functions

WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"

use 'bootstrap' && tc-bootstrap-musl "$(arch)-linux-musl$(usex x32 x32 '')-native.tgz"

pkginst \
  "dev-libs/gmp" \
  "dev-libs/mpfr" \
  "sys-devel/binutils" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'bootstrap' ||
pkginst \
  "#sys-devel/binutils" \
  "sys-devel/gcc" \
  "#sys-libs/musl"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed switch to build user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then

  cd "${DISTSOURCE}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  case $(tc-abi-build) in
    'x32')
      append-flags -mx32 -msse2
    ;;
    'x86')
      append-flags -m32 -msse -mfpmath=sse
    ;;
    'amd64')
      append-flags -m64 -msse2
    ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  use 'strip' && INSTALL_OPTS='install-strip'

	IFS=${NL}

  ./configure \
    ABI= \
    CC="gcc" \
    CXX="g++" \
    AR="ar" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(cpun)" || die "Failed make build"

  . runverb \
  make DESTDIR="${INSTALL_DIR}" ${INSTALL_OPTS} || die "make install... error"

  cd "${INSTALL_DIR}/" || die "install dir: not found... error"

  rm -r -- "usr/share/"

  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${INSTALL_DIR}/$(get_libdir) \
  ldd "$(get_libdir)/lib${PN}.so"

  exit
fi

cd "${INSTALL_DIR}/" || die "install dir: not found... error"

emptydir "${INSTALL_DIR}" && exit || chown -hR root:root -- "${INSTALL_DIR}/"*

INST_ABI="$(test-native-abi)" pkg-create-cgz
