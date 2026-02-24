#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-06-02 09:00 UTC, 2026-02-20 18:00 UTC - last change
# Build with useflag: -static -static-libs -shared -lfs -nopie -patch -doc -xstub -diet -musl -stest -strip +noarch

# http://data.gpo.zugaina.org/gentoo/app-i18n/translate-shell/translate-shell-0.9.7.1.ebuild

# BUG: make: gawk: No such file or directory  [close]

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

DESCRIPTION="Online command-line translator"
HOMEPAGE="https://www.soimort.org/translate-shell/"
LICENSE="Unlicense"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}; XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"; PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="0.9.7.1"
SRC_URI="https://github.com/soimort/${PN}/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"; USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
BUILD_CHROOT=${BUILD_CHROOT:-0}; BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
SRC_DIR="build"
IUSE="-test -doc -stest"
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
ZCOMP="gunzip"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
ABI_BUILD="${ABI_BUILD:-${1:?}}"
PROG="bin/trans"

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
  "sys-apps/gawk" \
  "sys-devel/make" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"  # only for user-build

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  sed -e "s;^#!/usr/bin/gawk;#!$(tc-getAWK);" -i ./build.awk

  make DESTDIR="${ED}" PREFIX="${EPREFIX%/}" install || die "make install... error"

  sed -e "s;^#!/usr/bin/.*;#!/bin/bash;" -i "${ED}"/bin/trans

  mkdir -m 0755 -- "${ED}"/usr/
  mv -n "${ED}"/share -t "${ED}"/usr/
  use 'doc' || rm -v -r -- "${ED}"/usr/share/man/ "${ED}"/usr/

  cd "${ED}/"

  use 'stest' && { ${PROG} -V || : die "binary work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="all" PN=${XPN} PV=${PV} pkg-create-cgz

pkg_postinst() {
  optfeature "all built-in translators (e.g. Apertium, Yandex)" net-misc/curl[ssl]
  optfeature "display text in right-to-left scripts" dev-libs/fribidi
  optfeature "text-to-speech functionality" media-sound/mpg123 app-accessibility/espeak-ng media-video/mpv
  optfeature "text-to-speech functionality" media-video/mplayer
  optfeature "interactive translation (REPL)" app-editors/emacs app-misc/rlwrap
  optfeature "spell checking" app-text/aspell app-text/hunspell
}
