#!/bin/sh
# Copyright (C) 2023-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-02-28 13:00 UTC - last change
# Build with useflag: +static -shared +compat -tcpd -diet +musl +x32

export USER XPN PF PV WORKDIR S PKGNAME DPREFIX BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:=$PWD}
XPN=${PN}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PV="2.3.15.4"
DESCRIPTION="Powerful replacement for inetd"
HOMEPAGE="https://github.com/xinetd-org/xinetd https://github.com/openSUSE/xinetd"
SITE="data.gpo.zugaina.org"
SRC_URI="
  https://github.com/openSUSE/xinetd/releases/download/${PV}/${PN}-${PV}.tar.xz
  http://${SITE}/gentoo/sys-apps/${PN}/files/${PN}-${PV}-0001-configure.ac-use-AC_USE_SYSTEM_EXTENSIONS.patch
  http://${SITE}/gentoo/sys-apps/${PN}/files/${PN}-${PV}-0002-redirect-drop-deprecated-sys-signal.h-include.patch
"
LICENSE="BSD"
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
IUSE="+static -shared +patch (+musl) (+ipv6) -debug +strip"
IUSE="${IUSE} +loadavg +compat -perl -rpc -sample -selinux -tcpd"
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
SDIR="${S}"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
PKGNAME=${PN}
ZCOMP="unxz"
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
S="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:${DPREFIX}/share/pkgconfig"
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
  "dev-util/pkgconf" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'patch' && {
pkginst \
  "dev-lang/perl" \
  "sys-devel/autoconf" \
  "sys-devel/automake" \
  "sys-devel/m4" \
  || die "Failed install build pkg depend... error"
}

use 'rpc' && pkginst "net-libs/libtirpc"
use 'selinux' && pkginst "sys-libs/libselinux"
use 'tcpd' && pkginst "sys-apps/tcp-wrappers"
use 'perl' && pkginst "dev-lang/perl"

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

  use 'patch' &&
  for F in "${FILESDIR}/${PN}-${PV}-"*".patch"; do
    patch -p1 -E < "${F}"
  done

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

  use 'strip' && INSTALL_OPTS='install-strip'

	IFS=${NL}

  . runverb \
  ./configure \
    CC="gcc$(use static && printf ' -static --static')" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_with 'tcpd' libwrap) \
    $(use_with 'selinux' labeled-networking) \
    $(use_with 'rpc') \
    $(use_with 'loadavg') \
    $(use_enable 'shared') \
    $(use_enable 'static') \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="$(usex static '-s -static --static ')${LDFLAGS}" \
    || die "configure... error"

  make -j "$(cpun)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  use 'sample' && cp -p contrib/xinetd.conf ${ED}/etc/"xinetd.conf.dist.sample"

  cd "${ED}/" || die "install dir: not found... error"

  rm -r -- "usr/"

  use 'perl' || rm -- "bin/xconv.pl"
  # convert: inetd.conf --> xinetd.conf
  use 'compat' || rm -- "bin/itox"

  # simple test
  use 'static' && LD_LIBRARY_PATH=
  sbin/${PN} -version

  ldd "sbin/${PN}" || { use 'static' && true;}

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
