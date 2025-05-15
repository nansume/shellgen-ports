#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-03-10 12:00 UTC - last change
# Build with useflag: +static +reverse-proxy +musl +x32

export USER XPN PF PV WORKDIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:-$PWD}
XPN=${PN}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
COMMIT="31339cb1615765f2fbb4ec7779400535bad6da46"
PV="1.11.1-p20230201"
DESCRIPTION="A lightweight HTTP/SSL proxy"
HOMEPAGE="https://github.com/tinyproxy/tinyproxy/"
SRC_URI="https://github.com/${PN}/${PN}/archive/${COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
LICENSE="GPL-2"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="linux"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static +filter-proxy +reverse-proxy (+musl) +patch -man -debug -test +strip"
IUSE="${IUSE} +transparent-proxy +upstream-proxy +xtinyproxy-header"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
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
ED=${INSTALL_DIR}
SDIR="${PDIR%/}/${SRC_DIR}"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
PKGNAME=${PN}
ZCOMP="gunzip"
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${COMMIT}"
S="${PDIR%/}/${SRC_DIR}/${PN}-${COMMIT}"
PWD=${PWD%/}; PWD=${PWD:-/}
ABI_BUILD="${ABI_BUILD:-${1:?}}"
XPN="${6:-${XPN:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}

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
  "dev-lang/perl" \
  "sys-devel/autoconf" \
  "sys-devel/automake" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/m4" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  sed -i -e 's| -Wp,-D_FORTIFY_SOURCE=2||' configure.ac || die "sed failed"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  use 'strip' && INSTALL_OPTS="install-strip"

	IFS=${NL}

  autoreconf --install

  . runverb \
  ./configure \
    CC="gcc$(usex static ' -static --static')" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --datarootdir="${DPREFIX}/share" \
    --localstatedir="/var" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'debug') \
    $(use_enable 'man' manpage_support) \
    $(use_enable 'filter-proxy' filter) \
    $(use_enable 'reverse-proxy' reverse) \
    $(use_enable 'transparent-proxy' transparent) \
    $(use_enable 'upstream-proxy' upstream) \
    $(use_enable 'xtinyproxy-header' xtinyproxy) \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="$(usex static '-s -static --static ')${LDFLAGS}" \
    || die "configure... error"

  make -j "$(cpun)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  rm -r -- "usr/share/doc/"

  use 'static' && LD_LIBRARY_PATH=
  bin/${PN} -v

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

ldd "bin/${PN}" || { use 'static' && true;}

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
