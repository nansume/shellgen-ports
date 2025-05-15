#!/bin/sh
# Copyright (C) 2021-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2023-11-10 16:00 UTC - last change
# Date: 2024-11-24 18:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl -stest -strip +noarch

# http://data.gpo.zugaina.org/gentoo/dev-libs/gnulib/gnulib-2024.01.01.10.31.48.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

DESCRIPTION="Library of common routines intended to be shared"
HOMEPAGE="https://www.gnu.org/software/gnulib"
LICENSE="GPL-3+ LGPL-2.1+ FDL-1.3+"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="2024.01.01"
PV="20220526"
TAG="5b92dd0a45c8d27f13a21076b57095ea5e220870"  # 2024.01.01 - GIT_TAG
TAG="5293ada82e1ea38e9e5cdd3724c73204d703f07b"  # 2022.05.26
SRC_URI="https://git.savannah.gnu.org/cgit/${PN}.git/snapshot/${PN}-${TAG}.tar.xz -> ${PN}-${PV}.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-doc"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${TAG}"
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
  "dev-lang/perl  # required for autotools" \
  "sys-apps/texinfo" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"  # only for user-build

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  find . \( -name '.git*' -o -name '.cvs*' \) -print0 | xargs -0 rm -rf

  sed -i '1s,#!/usr/local/bin,#!/bin,' lib/uniname/gen-uninames.lisp

  make -C doc info &&
  make -C doc html || exit

  mkdir -pm 0755 -- "${ED}/bin/" "${ED}/usr/share/${PN}/" "${ED}/usr/share/doc/${PN}-${PV}/"

  mv -n doc/*texi COPYING ChangeLog DEPENDENCIES -t "${ED}/usr/share/doc/${PN}-${PV}/"
  mv -n README NEWS* users.txt STATUS* -t "${ED}/usr/share/doc/${PN}-${PV}/"

  cp -a * -t "${ED}/${DPREFIX#/}/share/${PN}/"

  cd "${ED}/" || die "install dir: not found... error"

  ln -s ..${DPREFIX}/share/${PN}/check-module "bin/check-module"
  ln -s ..${DPREFIX}/share/${PN}/gnulib-tool "bin/gnulib-tool"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="all" PN=${XPN} PV=${PV} pkg-create-cgz
