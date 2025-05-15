#!/bin/sh
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-12-06 15:00 UTC - last change

NL="$(printf '\n\t')"; NL=${NL%?} XPWD=${XPWD:=$PWD} XPN=${PN} PKG_DIR='/pkg' LC_ALL='C'

PV="0.9.27-p20230223"
MY_COMMIT="29ae3ed4d5b83eec43598d6cd7949bccb41c8083"

DESCRIPTION="A very small C compiler for ix86/amd64"
HOMEPAGE="https://bellard.org/tcc/ https://repo.or.cz/tinycc.git/"
SRC_URI="https://repo.or.cz/tinycc.git/snapshot/${MY_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="LGPL-2.1"

USER=${USER:-root}
USE_BUILD_ROOT='0'
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=${PWD}
DPREFIX='/usr'
INCDIR="${DPREFIX}/include"
INSTALL_OPTS='install'
MAKEFLAGS='-j4 V=0'
HOSTNAME=$(hostname)
BUILD_USER='tools'
SRC_DIR='build'
IONICE_COMM='nice -n 19'
ZCOMP='gunzip'
IUSE="-test +static-libs +static"

export USER XPN PF PV LIBDIR WORKDIR PKGNAME DPREFIX
export LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI

if test "X${USER}" != 'Xroot'; then
  ABI_BUILD=${1:?} LIBDIR=${2:?} LIB_DIR=${3:?} PDIR=${4:?} XPWD=${5:?} XPN=${6:?}
  BUILD_CHROOT=${7:?} _ENV=${8} USE_BUILD_ROOT=${9} BUILDLIST=${10} CATEGORY=${11:?} PN=${12:?}
  PWD=${PWD%/}
  mksrc-prepare
elif test "${BUILD_CHROOT:=0}" -eq '0'; then
  PATH="${PATH:+${PATH}:}${PDIR}/misc.d:${PDIR}/etools.d"
elif test "${BUILD_CHROOT:=0}" -ne '0'; then
  PATH="$(xpath):${PDIR%/}/misc.d:${PDIR%/}/etools.d"
  printf %s\\n "PATH='${PATH}'" "PDIR='${PDIR}'"
fi

. "${PDIR%/}/etools.d/"pre-env || exit

test "x${SN}" != "x${SN%%_*}" && SN="${SN%%_*}-${SN#*_}"

PF=$(pfname 'src_uri.lst')
#PV=$(pkgver)
PKGNAME=$(pkgname)
ZCOMP=$(zcomp-as "${PF}")

printf %s\\n "BUILDLIST='${BUILDLIST}'" "PV='${PV}'" "PKGNAME='${PKGNAME}'"

chroot-build || exit

. "${PDIR%/}/etools.d/"pre-env-chroot
. "${PDIR%/}/etools.d/"build-functions

EPREFIX=${SPREFIX}
FILESDIR=${DISTSOURCE}
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"

pkginst \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

pkg-is "_dev-lang/tcc" &&

  pkginst "dev-lang/tcc" || pkginst "sys-devel/binutils" "sys-devel/gcc"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

no-ldconfig
netuser-fetch || die "Failed fetch sources... error"
sw-user || die "Failed switch to build user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  :
elif test "X${USER}" != 'Xroot'; then

  cd "${DISTSOURCE}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  WORKDIR=$(printf "${PDIR%/}/${SRC_DIR}/"*)

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  use 'x32' && append-flags -mx32
  append-flags -O2 -msse2 -fno-stack-protector -no-pie -g0 -march=$(tc-arch | sed 's/_/-/')

  use 'strip' && INSTALL_OPTS='install-strip'

  printf %s\\n "MAKEFLAGS='${MAKEFLAGS}'"
  printf %s\\n "CC='${CC}'" "CXX='${CXX}'" "CPP='${CPP}'" "LIBTOOL='${LIBTOOL}'"
  printf %s\\n "CFLAGS='${CFLAGS}'" "CPPFLAGS='${CPPFLAGS}'" "CXXFLAGS='${CXXFLAGS}'"
  printf %s\\n "FCFLAGS='${FCFLAGS}'" "FFLAGS='${FFLAGS}'" "LDFLAGS='${LDFLAGS}'"

	IFS=${NL}

  . runverb \
  ./configure \
    --cc="$(tc-getCC) $(use static && printf -static)" \
    --prefix="${SPREFIX%/}" \
    --bindir="${SPREFIX%/}/bin" \
    --libdir="${SPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --sharedir="${DPREFIX}/share" \
    --cpu=$(tc-arch) \
    --config-musl \
    --config-backtrace=no \
    $(use_enable 'rpath') \
    $(use_enable 'static-libs' static) || die "configure... error"

  make || die "Failed make build"

  . runverb \
  make DESTDIR="${INSTALL_DIR}" ${INSTALL_OPTS} || die "make install... error"

  cd "${INSTALL_DIR}/" || die "install dir: not found... error"

  post-inst-perm

  rm -r -- "${DPREFIX#/}/share/"

  pre-perm
  exit
fi

cd "${INSTALL_DIR}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(test-native-abi)" pkg-create-cgz
