#!/bin/sh
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-12-17 19:00 UTC - last change

NL="$(printf '\n\t')"; NL=${NL%?} XPWD=${XPWD:=$PWD} XPN=${PN} PKG_DIR='/pkg' LC_ALL='C'

PV="3.2.7"
DESCRIPTION="File transfer program to keep remote files into sync"
HOMEPAGE="https://rsync.samba.org/"
SRC_URI="http://www.mirrorservice.org/sites/rsync.samba.org/src/${PN}-${PV}.tar.gz"
SRC_URI="${SRC_URI}${NL} http://www.mirrorservice.org/sites/rsync.samba.org/src/${PN}-patches-${PV}.tar.gz"
LICENSE="GPL-3"
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
IUSE="-rpath -nls +static -acl -examples -iconv -lz4 -rrsync -ssl -openssl +detect-rename"
IUSE="${IUSE} +stunnel -system-popt -system-zlib -xattr -xxhash -zstd +strip"

export USER XPN PF PV WORKDIR PKGNAME DPREFIX BUILD_CHROOT
export LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTSOURCE FILESDIR INSTALL_DIR S SDIR

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

PDIR=${PWD}
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
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

chroot-build || exit

. "${PDIR%/}/etools.d/"pre-env-chroot
. "${PDIR%/}/etools.d/"build-functions

WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"

pkginst \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'detect-rename' &&
pkginst \
  "dev-lang/perl" \
  "sys-devel/autoconf" \
  "sys-devel/m4" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then

  cd "${DISTSOURCE}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PN}-patches-${PV}".tar.gz | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf -
  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  use 'strip' && INSTALL_OPTS='install-strip'

  if use 'detect-rename'; then
    patch -p1 -E < 'patches/detect-renamed.diff'
  fi
  export ac_cv_path_FAKEROOT_PATH="/bin/fakeroot"

	IFS=${NL}

  . runverb \
  ./configure \
    CC="gcc$(use static && printf ' -static --static')" \
    CXX="g++$(use static && printf ' -static --static')" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'debug') \
    --disable-iconv-open \
    --disable-iconv \
    $(use_with !system-zlib included-zlib) \
    $(use_with !system-popt included-popt) \
    $(use_enable 'nls' locale) \
    --disable-lz4 \
    --disable-md2man \
    --disable-openssl \
    --disable-acl-support \
    --disable-xattr-support \
    --disable-zstd \
    --disable-xxhash \
    $(use 'static' && printf "LDFLAGS=-s -static --static") \
    || die "configure... error"

  make -j "$(cpun)" || die "Failed make build"

  . runverb \
  make DESTDIR="${INSTALL_DIR}" ${INSTALL_OPTS} || die "make install... error"

  if use 'stunnel'; then
    . runverb \
    make DESTDIR="${INSTALL_DIR}" install-ssl-daemon || die "Install stunnel helpers... error"
  fi

  cd "${INSTALL_DIR}/" || die "install dir: not found... error"

  rm -r -- "usr/"

  # simple test
  LD_LIBRARY_PATH= bin/${PN} --version || die "binary work... error"
  ldd "bin/${PN}" || { use 'static' && true;}

  exit
fi

cd "${INSTALL_DIR}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(test-native-abi)" pkg-create-cgz
