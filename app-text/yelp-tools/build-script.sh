#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-06-01 12:00 UTC, 2026-02-20 23:00 UTC - last change
# Build with useflag: -static -static-libs -shared -lfs -nopie -patch -doc -xstub -diet +musl +stest -strip +noarch

# http://data.gpo.zugaina.org/gentoo/app-text/yelp-tools/yelp-tools-42.1-r1.ebuild

# BUG: ERROR: Dependency `yelp-xsl` not found  [close]

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Collection of tools for building and converting documentation"
HOMEPAGE="https://wiki.gnome.org/Apps/Yelp/Tools"
LICENSE="|| ( GPL-2+ freedist ) GPL-2+"  # yelp.m4 is GPL2 || freely distributable
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="42.1"
SRC_URI="https://download.gnome.org/sources/yelp-tools/${PV%.*}/${PN}-${PV}.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-doc +stest"
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
PROG="bin/yelp-new"

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
  "#dev-build/cmake3  # it optional?" \
  "dev-build/meson7  # build tool" \
  "#dev-build/muon  # alternative for meson" \
  "dev-build/samurai  # alternative for ninja" \
  "dev-lang/python3-8  # deps meson" \
  "dev-libs/expat  # deps meson,python" \
  "dev-libs/libffi  # deps meson" \
  "dev-libs/libxml2-1" \
  "dev-libs/libxslt" \
  "#dev-python/py38-cython" \
  "dev-python/py38-lxml" \
  "dev-python/py38-setuptools" \
  "dev-util/itstool" \
  "dev-util/pkgconf" \
  "gnome-extra/yelp-xsl" \
  "sys-devel/m4  # required for ninja" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps meson" \
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

  inherit gnome2 meson python-single-r1

  . "${PDIR%/}/etools.d/"epython

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  #cd "${BUILD_DIR}/" || die "builddir: not found... error"

  meson setup \
    -D prefix="/" \
    -D bindir="bin" \
    -D datadir="usr/share" \
    -D wrap_mode="nodownload" \
    -D buildtype="release" \
    -D b_colorout="never" \
    -D b_pie="false" \
    -D strip=$(usex 'strip' true false) \
    "${BUILD_DIR}/build" "${BUILD_DIR}" \
    || die "meson setup... error"

  ninja -j "$(nproc)" -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${ED}" meson install --no-rebuild -C "${BUILD_DIR}/build" || die "meson install... error"

  python_fix_shebang "${ED}"/bin/yelp-build "${ED}"/bin/yelp-check "${ED}"/bin/yelp-new

  cd "${ED}/" || die "install dir: not found... error"

  use 'stest' && { ${PROG} --help || : die "binary work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz