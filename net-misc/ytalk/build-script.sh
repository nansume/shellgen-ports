#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-03-14 18:00 UTC - last change
# Build with useflag: +static -man -diet +musl +x32

export USER XPN PF PV WORKDIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:-$PWD}
XPN=${PN}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PV="3.3.0"
DESCRIPTION="A multi-user chat program that works exactly like UNIX's talk."
HOMEPAGE="http://packages.debian.org/sid/ytalk"
SRC_URI="
  http://ftp.debian.org/debian/pool/main/y/${PN}/${PN}_${PV}.orig.tar.gz
  http://ftp.debian.org/debian/pool/main/y/${PN}/${PN}_${PV}-9.debian.tar.xz
"
LICENSE="GPL"
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
IUSE="+static -diet (+musl) -man -debug (-test) +strip"
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

pkginst \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-libs/netbsd-curses" \
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
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  for F in *.tar.xz; do
    unxz -dc ${F} | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf -
    printf %s\\n "unxz -dc ${F} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  for F in $(sed -e 's:^:../debian/patches/:' ../debian/patches/series || die); do
    printf '%s\n' "patch -p1 -E < ${F}"
    test -f "${F}" && patch -p1 -E < "${F}"
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

  use 'static' && LD_LIBRARY_PATH=
  use 'strip' && INSTALL_OPTS="install-strip"
  use 'diet' && PATH="${PATH:+${PATH}:}/opt/diet/bin"

	IFS=${NL}

  . runverb \
  ./configure \
    CC=$(usex diet 'diet -Os gcc -nostdinc' "gcc$(usex static ' -static --static')" ) \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libexecdir="${DPREFIX}/libexec" \
    --datadir="${DPREFIX}/share" \
    --mandir="${DPREFIX}/share/man" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'debug') \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="$(use diet || usex static '-s -static --static ')${LDFLAGS}" \
    || die "configure... error"

  make -j "$(use diet && printf 1 || cpun)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'man' || rm -r -- "usr/"

  use 'static' && LD_LIBRARY_PATH=
  bin/${PN} -v || die "binary work... error"

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

ldd "bin/${PN}" || { use 'static' && true;}

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
