#!/bin/sh
# Copyright (C) 2023-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-01-15 11:00 UTC - last change
# Build with useflag: +diet -vname -maildir +mbox +passwd -standalone +x32

export USER XPN PF PV WORKDIR S PKGNAME DPREFIX BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:=$PWD}
XPN=${PN}
PKG_DIR='/pkg'
LC_ALL='C'
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PV="1.0.3"
DESCRIPTION="A security oriented POP3 server"
HOMEPAGE="https://www.openwall.com/popa3d/"
SRC_URI="
  http://www.openwall.com/${PN}/${PN}-${PV}.tar.gz
  rsync://mirror.bytemark.co.uk/gentoo/distfiles/*/${PN}-0.6.3-vname-2.diff.gz
  rsync://mirror.bytemark.co.uk/gentoo/distfiles/*/${PN}-0.5.9-maildir-2.diff.gz
  https://www.openwall.com/lists/popa3d-users/2010/11/09/1/1 -> ${PN}-1.0.2-vnamemap-dir.diff
"
LICENSE="Openwall"
USER=${USER:-root}
USE_BUILD_ROOT='0'
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX='/usr'
INCDIR="${DPREFIX}/include"
HOSTNAME='linux'
BUILD_USER='tools'
SRC_DIR='build'
IONICE_COMM='nice -n 19'
IUSE="+static +patch (-musl) (-glibc) -test -debug +strip"
IUSE="${IUSE} +rsync -pam -shadow -passwd -mbox +maildir +diet -tcpd"
IUSE="${IUSE} +vname +vnamemap +inetd (-standalone) -opts"
# buildflag testing.
IUSE="${IUSE} -vname -maildir +mbox +passwd"
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
ZCOMP='gunzip'
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
S="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
ABI_BUILD="${ABI_BUILD:-${1:?}}"
XPN="${6:-${XPN:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
PATCH='/bin/gpatch'

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
  || die "Failed install build pkg depend... error"

use 'patch' && pkginst "sys-devel/patch"

if use 'diet'; then
  IUSE="${IUSE} +static"
  pkginst "dev-libs/dietlibc"
else
  IUSE="${IUSE} -diet"
  pkginst "sys-libs/musl"
fi

use 'rsync' && pkginst "net-misc/rsync"
use 'tcpd' && pkginst "sys-apps/tcp-wrappers"

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

  use 'vname' && {
  gunzip -dc "${FILESDIR}/${PN}-0.6.3-vname-2.diff.gz" | ${PATCH} -p1 -E
   use 'vnamemap' &&
   ${PATCH} -E < "${FILESDIR}/${PN}-1.0.2-vnamemap-dir.diff"
  }
  use 'maildir' && gunzip -dc "${FILESDIR}/${PN}-0.5.9-maildir-2.diff.gz" | ${PATCH} -p1 -E

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

  if use 'pam' || use 'passwd' || use 'shadow'; then
    :
  else
    POPA3D_VIRTUAL_ONLY='YES'
    POPA3D_VIRTUAL_HOME_PATH="/opt/${PN}/vhome"
  fi

  MAX_SESSIONS='50'                 # Default is 500
  MAX_SESSIONS_PER_SOURCE='5'       # Default is 50

  MAX_MAILBOX_MESSAGES='10000'      # Default is 2097152
  MAX_MAILBOX_OPEN_BYTES='10000000' # Default is 2147483647
  MAX_MAILBOX_WORK_BYTES='15000000' # Default is 2147483647

  sed -i \
   -e "s:^\(#define MAX_SESSIONS\) .*$:\1 ${MAX_SESSIONS}:" \
   -e "s:^\(#define MAX_SESSIONS_PER_SOURCE\).*$:\1 ${MAX_SESSIONS_PER_SOURCE}:" \
   -e "s:^\(#define MAX_MAILBOX_MESSAGES\).*$:\1 ${MAX_MAILBOX_MESSAGES}:" \
   -e "s:^\(#define MAX_MAILBOX_OPEN_BYTES\).*$:\1 ${MAX_MAILBOX_OPEN_BYTES}:" \
   -e "s:^\(#define MAX_MAILBOX_WORK_BYTES\).*$:\1 ${MAX_MAILBOX_WORK_BYTES}:" \
   params.h || die "sed on params.h failed"

  use 'tcpd' && sed -i -e "s:^\(#define DAEMON_LIBWRAP\) .*$:\1 1:" params.h

  if use 'maildir'; then
    printf %s\\n "Mailbox format is: MAILDIR."
    if test -z "${POPA3D_HOME_MAILBOX}"; then
      POPA3D_HOME_MAILBOX=".maildir"
    fi
  else
    printf %s\\n "Mailbox format is: MAILBOX."
    # Original: MAIL_SPOOL_PATH=/var/mail
    #MAIL_SPOOL_PATH="/var/spool/mail"
    #sed -i \
    #  -e "s:^\(#define MAIL_SPOOL_PATH\).*$:\1 \"${MAIL_SPOOL_PATH}\":" \
    #  params.h || die "sed on params.h failed"
    printf %s\\n "Mailbox path: ${MAIL_SPOOL_PATH:-/var/mail}/username"
  fi

  if test "x${POPA3D_VIRTUAL_ONLY}" = 'xYES'; then
    printf %s\\n "Virtual only, no local system users"
    sed -i -e "s:^\(#define VIRTUAL_ONLY\).*$:\1 1:" \
    params.h || die "sed on param.h failed"
  fi

  if test -n "${POPA3D_VIRTUAL_HOME_PATH}"; then
    printf %s\\n "Virtual home path set to: ${POPA3D_VIRTUAL_HOME_PATH}"
    sed -i \
     -e "s:^\(#define VIRTUAL_HOME_PATH\).*$:\1 \"$POPA3D_VIRTUAL_HOME_PATH\":" \
     params.h || die "sed on params.h failed"
  fi

  use 'opts' && sed -i "s:^\(#define POP_OPTIONS\).*$:\1 0:" params.h

  if test "x${POPA3D_VIRTUAL_ONLY}" = 'xYES'; then
    printf %s\\n "Authentication method: Virtual."
    sed -i \
     -e "s:^\(#define AUTH_PASSWD\)[[:blank:]].*$:\1 0:" \
     -e "s:^\(#define AUTH_SHADOW\)[[:blank:]].*$:\1 0:" \
     params.h || die "sed on params.h failed"
  elif use 'pam'; then
    printf %s\\n "Authentication method: PAM."
    : append-libs -lpam
    sed -i \
     -e "s:^\(#define AUTH_SHADOW\)[[:blank:]].*$:\1 0:" \
     -e "s:^\(#define AUTH_PAM\)[[:blank:]].*$:\1 1:" \
     params.h || die "sed on params.h failed"
  elif use 'passwd'; then
    printf %s\\n "Authentication method: Passwd."
    sed -i \
      -e "s:^\(#define AUTH_PASSWD\)[[:blank:]].*$:\1 1:" \
      -e "s:^\(#define AUTH_SHADOW\)[[:blank:]].*$:\1 0:" \
      params.h || die "sed on params.h failed"
  else
    printf %s\\n "Authentication method: Shadow."
  fi

  use 'standalone' && sed -i -e "s:^\(#define POP_STANDALONE\).*$:\1 1:" params.h

  use 'vname' &&
  sed -i \
   -e "s:^\(#define POP_VIRTUAL\).*$:\1 1:" \
   -e "s:^\(#define VIRTUAL_VNAME\).*$:\1 1:" \
   params.h

  sed -i \
   -e '/^CC =/d' \
   -e '/^CFLAGS =/d' \
   -e '/^LDFLAGS =/d' \
   Makefile || die "Makefile cleaning failed"

  use 'diet' && PATH="${PATH:+${PATH}:}/opt/diet/bin"

  IFS=${NL}

  . runverb \
  make -j "$(cpun)" \
    CC=$(usex diet 'diet -Os gcc -nostdinc' "gcc$(usex static ' -static --static')" ) \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    DESTDIR="${ED}" \
    PREFIX="${EPREFIX%/}" \
    SBINDIR="${EPREFIX%/}/sbin" \
    MANDIR="${EPREFIX%/}/usr/share/man" \
    $(use 'static' && printf "LDFLAGS=-s -static --static") \
    all install || die "Failed make build or install... error"

  cd "${ED}/" || die "install dir: not found... error"

  rm -r -- "usr/"

  use 'strip' && strip --verbose --strip-all "sbin/${PN}"

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

ldd "sbin/${PN}" || { use 'static' && true;}

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
