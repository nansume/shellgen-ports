#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-01-28 13:00 UTC - last change
# Build with useflag: +diet -syslog +x32

export USER XPN PF PV WORKDIR S PKGNAME DPREFIX BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:=$PWD}
XPN=${PN}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PV="26.1"
DESCRIPTION="An IRC server written from scratch"
HOMEPAGE="https://ngircd.barton.de/"
SRC_URI="http://distfiles.alpinelinux.org/distfiles/edge/${PN}-${PV}.tar.xz"
LICENSE="GPL-2"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INSTALL_OPTS="install"
HOSTNAME="linux"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static (-ssl) (-musl) (+syslog) (-patch) +ipv6 (-zlib) +diet -debug -test +strip"
IUSE="${IUSE} (-gnutls) (-openssl) (-ident) (+irc-plus) (-pam) (-strict-rfc) (-tcpd)"
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
ED=${INSTALL_DIR}
SDIR="${PDIR%/}/${SRC_DIR}"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
PKGNAME=${PN}
ZCOMP="unxz"
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
S="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
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

use 'ssl' && IUSE="${IUSE} +gnutls"
use 'gnutls' && IUSE="${IUSE} +ssl"

pkginst \
  "dev-util/pkgconf" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  || die "Failed install build pkg depend... error"

if use 'diet'; then
  # tool.c:167:16: error: redefinition of <struct _code> - diet/include/syslog.h
  IUSE="${IUSE} -syslog"
  pkginst "dev-libs/dietlibc"
else
  pkginst "sys-libs/musl"
fi

if use 'gnutls' || use 'ssl'; then
  pkginst \
    "dev-libs/libtasn1" \
    "dev-libs/libunistring" \
    "dev-libs/nettle" \
    "net-libs/gnutls" \
    || die "Failed install build pkg depend... error"
elif use 'openssl'; then
  pkginst "dev-libs/openssl3"
fi

use 'ident' && pkginst "net-libs/libident"
use 'pam' && pkginst "sys-libs/pam"
use 'tcpd' && pkginst "sys-apps/tcp-wrappers"
use 'zlib' && pkginst "sys-libs/zlib"

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

  use 'diet' && PATH="${PATH:+${PATH}:}/opt/diet/bin"
  use 'strip' && INSTALL_OPTS="install-strip"

	IFS=${NL}

  . runverb \
  ./configure \
    CC=$(usex diet 'diet -Os gcc -nostdinc' "gcc$(usex static ' -static --static')" ) \
    --prefix="${EPREFIX%/}" \
    --sbindir="${EPREFIX%/}/sbin" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'debug') \
    $(use_enable 'irc-plus' ircplus) \
    $(use_enable 'ipv6') \
    $(use_with 'syslog') \
    $(use_with 'irc-plus' iconv) \
    $(use_with 'ident') \
    $(use_with 'tcpd' tcp-wrappers) \
    $(use_with 'zlib') \
    $(use_with 'ssl' gnutls) \
    $(use_with 'openssl') \
    $(use 'static' && printf "LDFLAGS=-s -static --static") \
    || die "configure... error"

  make -j "$(cpun)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  rm -r -- "usr/"

  use 'static' && LD_LIBRARY_PATH=
  sbin/${PN} -V

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

ldd "sbin/${PN}" || { use 'static' && true;}

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
