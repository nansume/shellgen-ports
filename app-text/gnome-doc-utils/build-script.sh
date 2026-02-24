#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-05-31 21:00 UTC, 2026-02-16 19:00 UTC - last change
# Build with useflag: -static -static-libs -shared -lfs -nopie +patch -doc -xstub -diet -musl +stest -strip +noarch

# http://data.gpo.zugaina.org/gentoo/app-text/gnome-doc-utils/gnome-doc-utils-0.20.10-r3.ebuild
# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=gnome-doc-utils

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="A collection of documentation utilities for the Gnome project"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeDocUtils"
LICENSE="GPL-2 LGPL-2.1"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PV="0.20.10"
SRC_URI="
  https://download.gnome.org/sources/gnome-doc-utils/${PV%.*}/${PN}-${PV}.tar.xz
  http://localhost/pub/distfiles/patch/${PN}-${PV}-fix-out-of-tree-build.patch
  https://dev.gentoo.org/~juippis/distfiles/tmp/${PN}-${PV}-python3.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+locale -doc +stest"
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
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
PROG="bin/gnome-doc-tool"

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
  "app-text/docbook-xml-dtd44" \
  "app-text/scrollkeeper-dtd" \
  "#dev-build/autoconf71  # required for autotools" \
  "#dev-build/automake16  # required for autotools" \
  "#dev-build/libtool9  # required for autotools,libtoolize" \
  "dev-lang/perl  # required for autotools" \
  "dev-lang/python3-8" \
  "dev-libs/expat  # deps python" \
  "dev-libs/libxml2-1  # required: libxml2[python]" \
  "dev-libs/libxslt" \
  "dev-perl/perl-xml-parser" \
  "dev-util/intltool" \
  "dev-util/pkgconf" \
  "sys-devel/binutils9" \
  "sys-devel/gcc9" \
  "sys-devel/gettext  # required for autotools (optional)" \
  "#sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
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

  . "${PDIR%/}/etools.d/"epython

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  CC="cc" CXX="c++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # Stop build from relying on installed package
  gpatch -p1 -E < "${FILESDIR}"/${PN}-${PV}-fix-out-of-tree-build.patch
  gpatch -p1 -E < "${DISTDIR}"/${PN}-${PV}-python3.patch

  # Empty py-compile, so it doesn't write its own pyo/pyc files
  echo > "${BUILD_DIR}"/py-compile
  chmod a+x "${BUILD_DIR}"/py-compile || die

  #rm -- m4/glib-gettext.m4
  #sed 's/SUBDIRS = .*/SUBDIRS = /' -i doc/Makefile.am
  #NOCONFIGURE=1 ./autogen.sh

  PYTHON="/bin/python3" \
  ./configure \
    --prefix="${EPREFIX}" \
    --bindir="${EPREFIX%/}/bin" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --disable-scrollkeeper \
    --disable-nls \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  mv -v -n lib/locale -t usr/share/

  use 'doc' || rm -v -r -- "usr/share/doc/" "usr/share/man/"
  lang-rm

  use 'stest' && { ${PROG} --version || die "script work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="all" PN=${XPN} PV=${PV} pkg-create-cgz