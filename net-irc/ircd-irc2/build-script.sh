#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-01-16 23:00 UTC - last change
# Build with useflag: -diet +patch +ipv6 +static +x32

# BUG: build with diet-libc too buggy

export USER XPN PF PV WORKDIR S PKGNAME DPREFIX BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:=$PWD}
XPN=${PN}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PV="2.11.2p3"
DESCRIPTION="your true Internet Relay Chat (inetd,standalone)"
HOMEPAGE="http://www.irc.org/"
SRC_URI="
  http://deb.debian.org/debian/pool/main/i/${PN}/${PN}_${PV}~dfsg.orig.tar.gz
  http://deb.debian.org/debian/pool/main/i/${PN}/${PN}_${PV}~dfsg-7~bpo11+1.debian.tar.xz
"
LICENSE=""
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
HOSTNAME="linux"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static (-ssl) (-musl) +patch +ipv6 -zlib -dsm (-diet) +strip"
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
ZCOMP="gunzip"
WORKDIR="${PDIR%/}/${SRC_DIR}/irc${PV}"
S="${PDIR%/}/${SRC_DIR}/irc${PV}"
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
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

if use 'diet'; then
  pkginst "dev-libs/dietlibc"
fi

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

  use 'patch' &&
  unxz -dc "${PN}_${PV}~dfsg-7~bpo11+1.debian.tar.xz" \
  | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf -

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  use 'patch' &&
  for F in $(sed -e 's:^:../debian/patches/:' ../debian/patches/series || die); do
    printf %s\\n "file: ${F}"
    patch -p1 -E < "${F}"
  done

  # make fails s_bsd.c:533:8: error: too many arguments to function <setpgrp>.
  # https://bugs.unrealircd.org/view.php?id=5460
  sed -i -e 's:setpgrp:setpgid:' ircd/s_bsd.c

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

  LDFLAGS="$(usex static '-s -static --static ')${LDFLAGS}"

  use 'diet' && PATH="${PATH:+${PATH}:}/opt/diet/bin"

	IFS=${NL}

  # required addition sysconf dir: etc/ircd.conf -> etc/ircd/*.conf
  . runverb \
  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --libexecdir="${DPREFIX}/libexec" \
    --datadir="${DPREFIX}/share" \
    --host=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
    --build=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
    $(use_with 'zlib') \
    $(use_enable 'ipv6') \
    $(use_enable 'dsm') \
    || die "configure... error"

  WORKDIR="${WORKDIR}/$(arch)-unknown-linux-gnu"
  cd "${WORKDIR}/" || die "workdir: not found... error"

  make -j "$(cpun)" \
    CC=$(usex diet 'diet -Os gcc -nostdinc' "gcc$(usex static ' -static --static')" ) \
    all || die "Failed make build"

  mkdir -pm 0755 "${ED}/etc/ircd/" "${ED}/sbin/"
  cp -p chkconf iauth ircd ircd-mkpasswd ircdwatch "${ED}/sbin/"

  cp -p ../../debian/maint/ircd.conf "${ED}/etc/ircd/"
  cp -p ../../debian/maint/ircd.motd "${ED}/etc/ircd/"
  cp -p ../../debian/maint/iauth.conf "${ED}/etc/ircd/"
  printf %s\\n "Install... ok"

  cd "${ED}/" || die "install dir: not found... error"

  use 'strip' && strip --verbose --strip-all "sbin/"*

  use 'static' && LD_LIBRARY_PATH=
  sbin/ircd -v
  ldd "sbin/ircd" || { use 'static' && true;}

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
