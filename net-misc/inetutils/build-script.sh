#!/bin/sh
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-12-25 18:00 UTC - last change

export USER XPN PF PV WORKDIR PKGNAME DPREFIX BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR S SDIR

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:=$PWD}
XPN=${PN}
PKG_DIR='/pkg'
LC_ALL='C'
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PV="2.4"
DESCRIPTION="Collection of common network programs"
HOMEPAGE="https://www.gnu.org/software/inetutils/"
SRC_URI="http://ftp.gnu.org/gnu/${PN}/${PN}-${PV}.tar.xz"
LICENSE="GPL-3+"
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
ZCOMP='unxz'
IUSE="-rpath +static (-musl) -test +strip"
IUSE="${IUSE} -idn -kerberos -pam +tcpd"
IUSE="${IUSE} +ftpd +inetd +rexecd -rlogind -rshd -syslogd -talkd -telnetd -tftpd +uucpd"
IUSE="${IUSE} -ftp -dnsdomainname -hostname -ping -ping6 -rcp +rexec -rlogin -rsh"
IUSE="${IUSE} -logger -telnet -tftp -whois -ifconfig -traceroute"
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
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
BUILDLIST=${10:-$BUILDLIST}
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
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'tcpd' && pkginst "sys-apps/tcp-wrappers"

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
    CC="gcc$(usex static ' -static --static')" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-clients \
    --disable-servers \
    --without-idn \
    --without-krb4 \
    --without-krb5 \
    --without-shishi \
    --without-pam \
    $(use_with 'tcpd' wrap) \
    $(use_enable 'ftpd') \
    $(use_enable 'inetd') \
    $(use_enable 'rexecd') \
    $(use_enable 'rlogind') \
    $(use_enable 'rshd') \
    $(use_enable 'syslogd') \
    $(use_enable 'talkd') \
    $(use_enable 'telnetd') \
    $(use_enable 'tftpd') \
    $(use_enable 'uucpd') \
    $(use_enable 'ftp') \
    $(use_enable 'dnsdomainname') \
    $(use_enable 'hostname') \
    $(use_enable 'ping') \
    $(use_enable 'ping6') \
    $(use_enable 'rcp') \
    $(use_enable 'rexec') \
    $(use_enable 'rlogin') \
    $(use_enable 'rsh') \
    $(use_enable 'logger') \
    $(use_enable 'telnet') \
    $(use_enable 'tftp') \
    $(use_enable 'whois') \
    $(use_enable 'ifconfig') \
    $(use_enable 'traceroute') \
    $(use_enable 'rpath') \
    $(use 'static' && printf "LDFLAGS=-s -static --static") \
    || die "configure... error"

  make -j "$(cpun)" || die "Failed make build"

  . runverb \
  make DESTDIR="${INSTALL_DIR}" ${INSTALL_OPTS} || die "make install... error"

  cd "${INSTALL_DIR}/" || die "install dir: not found... error"

  rm -r -- "bin/ftp" "usr/share/"

  # simple test
  use 'static' && LD_LIBRARY_PATH=
  usr/libexec/inetd --version || die "binary work... error"

  ldd "usr/libexec/inetd" || { use 'static' && true;}

  exit 0
fi

cd "${INSTALL_DIR}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
