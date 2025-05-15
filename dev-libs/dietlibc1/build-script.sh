#!/bin/sh
# Copyright (C) 2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-04-16 23:00 UTC - last change
# Build with useflag: -static +static-libs -shared -lfs +nopie -patch -doc -xstub -diet -musl +stest +strip +amd64

# BUG: nobuild x32abi
# BUG: gcc <opts> -I. -isystem include <opts> -fpie -c syscalls.s/close_range.S <opts> -o bin-x32/close_range.o
# BUG: syscalls.s/close_range.S: Assembler messages:
# BUG: syscalls.s/close_range.S:3: Error: non-constant expression in `.if` statement
# BUG: make[1]: *** [Makefile:204: bin-x32/close_range.o] Error 1

# http://data.gpo.zugaina.org/gentoo/dev-libs/dietlibc/dietlibc-0.34.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="A libc optimized for small size"
HOMEPAGE="http://www.fefe.de/dietlibc/"
LICENSE="GPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN} #XPN=${PN}
PN=${PN%[0-9]*}
PV="0.34"  # release: 20180924 (x32,amd64,x86)
PV="0.35"  # release: 20241031 (amd64,x86)
SRC_URI="
  http://www.fefe.de/${PN}/${PN}-${PV}.tar.xz
  #http://ftp.debian.org/debian/pool/main/d/${PN}/${PN}_${PV}~cvs20160606-14.debian.tar.xz
  #https://raw.githubusercontent.com/pld-linux/${PN}/master/x32-fixes.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static-libs -doc (-musl) +stest +strip"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
P="${P:-${XPWD##*/}}"
SN=${P}
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
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
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
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl  # required for: dietlibc-0.35" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  if use 'x86'; then
    ln -s gcc bin/i386-linux-gcc
    ln -s ar bin/i386-linux-ar
  elif use 'amd64'; then
    ln -s gcc bin/$(arch)-linux-gcc
    ln -s ar bin/$(arch)-linux-ar
  fi
fi

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -fno-stack-protector;;
    'x86')   append-flags -m32  ;;
    'amd64') append-flags -m64  ;;
  esac
  append-flags -Os -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc -D__dietlibc__ -I. -isystem include"

  # Makefile does not append CFLAGS
  append-flags \
    -W -Wall -Wchar-subscripts \
    -Wmissing-prototypes -Wmissing-declarations -Wno-switch \
    -Wno-unused -Wredundant-decls -fno-strict-aliasing

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  # patch for old version(v0.33): x32-fixes.patch
  #use x32 && epatch

  sed -e 's:strip::' -i Makefile || die
  append-flags -Wa,--noexecstack

  printf %s\\n "CFLAGS='${CFLAGS}'"

  use 'x32' && ln -s bin-x32 bin-$(tc-arch)

  DIETHOME="/opt/diet"

  . runverb \
  make -j1 \
    CC="${CC}" \
    CFLAGS="${CFLAGS}" \
    prefix="${DIETHOME}" \
    BINDIR="${DIETHOME}/bin" \
    MAN1DIR="${DPREFIX}/share/man/man1" \
    DESTDIR="${INSTALL_DIR}" \
    STRIP=":" \
    $(use 'x32' && printf "x32") \
    $(use 'x86' && printf "i386") \
    $(use 'amd64' && printf "$(arch)") \
    install-bin install-headers || die "make build... error"

  cd "${ED}/" || die "install dir: not found... error"
  rm -r -- "${DPREFIX#/}/share/" "${DPREFIX#/}/"

  cd "${ED}${DIETHOME}/" || die "install dir: not found... error"

  use 'x32' && ln -sf "lib-$(arch)" "lib-$(tc-abi)"

  strip --verbose --strip-all "bin/"*
  #strip --strip-unneeded  lib-$(arch)/*
  strip --strip-unneeded  "lib-"*"/"*
  #strip --strip-unneeded  $(get_libdir)/${PN}/*

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz