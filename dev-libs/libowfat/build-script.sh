#!/bin/sh
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-12-18 16:00 UTC - last change

NL="$(printf '\n\t')"; NL=${NL%?} XPWD=${XPWD:=$PWD} XPN=${PN} PKG_DIR='/pkg' LC_ALL='C'

PV="0.33"
DESCRIPTION="reimplement libdjb - excellent libraries from Dan Bernstein"
HOMEPAGE="http://www.fefe.de/libowfat/"
SRC_URI="http://www.fefe.de/${PN}/${PN}-${PV}.tar.xz"
LICENSE="GPL-2"
USER=${USER:-root}
USE_BUILD_ROOT='0'
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=${PWD}
DPREFIX='/usr'
INCDIR="${DPREFIX}/include"
HOSTNAME=$(hostname)
BUILD_USER='tools'
SRC_DIR='build'
IONICE_COMM='nice -n 19'
ZCOMP='unxz'
IUSE="+static-libs (-musl) +diet +strip"

export USER XPN PF PV WORKDIR PKGNAME DPREFIX BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR S SDIR

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

PDIR=$(pkg-rootdir)
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
DPREFIX="/usr"
P=${XPWD##*/}
SN=${P}
PN=${P%%_*}
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

. "${PDIR%/}/etools.d/"build-functions

chroot-build || die "Failed chroot... error"

pkginst \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  || die "Failed install build pkg depend... error"

if use 'diet'; then
  pkginst "dev-libs/dietlibc"
else
  pkginst "sys-libs/musl"
fi

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

  # Required for mult/umult64.c to be usable
  # http://data.gpo.zugaina.org/gentoo/dev-libs/libowfat/libowfat-0.33-r1.ebuild
  append-flags -fomit-frame-pointer

  use 'diet' && PATH="${PATH:+${PATH}:}/opt/diet/bin"

	IFS=${NL}

	make headers

  . runverb \
  make -j "$(cpun)" \
    CC="$(use diet && printf 'diet -Os gcc -nostdinc' || printf gcc)" \
    CFLAGS="-I. ${CFLAGS}" \
    DESTDIR="${INSTALL_DIR}" \
    prefix="${EPREFIX%/}" \
    LIBDIR="${EPREFIX%/}/$(get_libdir)" \
    INCLUDEDIR="${INCDIR}" \
    MAN3DIR="${DPREFIX}/share/man/man3" \
    DIET="" \
    all install \
    || die "Failed make build"

  cd "${INSTALL_DIR}/" || die "install dir: not found... error"

  rm -r -- "usr/share/"

  use 'strip' && strip --strip-unneeded "$(get_libdir)/libowfat.a"

  exit 0
fi

cd "${INSTALL_DIR}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
