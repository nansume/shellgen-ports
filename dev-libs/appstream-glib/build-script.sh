#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2024-11-12 15:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs -nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-libs/appstream-glib/appstream-glib-0.8.2.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Provides GObjects and helper methods to read and write AppStream metadata"
HOMEPAGE="https://people.freedesktop.org/~hughsient/appstream-glib/ https://github.com/hughsie/appstream-glib"
LICENSE="LGPL-2.1+"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="0.8.2"
SRC_URI="https://people.freedesktop.org/~hughsient/${PN}/releases/${PN}-${PV}.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-static-libs +shared -doc (+musl) +stest +strip"
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
PROG="appstream-util"

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
  "app-arch/libarchive" \
  "app-text/docbook-xsl-stylesheets" \
  "app-text/docbook-xml-dtd42" \
  "dev-build/meson7  # build tool" \
  "#dev-build/muon  # BUG: build... Failed" \
  "dev-build/samurai  # alternative for ninja" \
  "dev-lang/python38  # deps meson" \
  "dev-libs/expat  # deps meson" \
  "dev-libs/glib74" \
  "dev-libs/json-glib" \
  "dev-libs/libffi  # deps meson" \
  "dev-libs/libxml2" \
  "dev-libs/libxslt" \
  "dev-libs/libyaml" \
  "dev-libs/pcre  # deps glib69" \
  "dev-libs/pcre2  # deps glib74" \
  "dev-libs/openssl3  # deps libarchive" \
  "dev-python/py38-importlib-resources  # for meson (build tool)" \
  "dev-python/py38-mako" \
  "dev-python/py38-setuptools  # for meson (build tool)" \
  "dev-python/py38-zipp  # for meson (build tool)" \
  "dev-util/gperf" \
  "dev-util/cmake  # it optional?" \
  "dev-util/pkgconf" \
  "media-libs/freetype  # deps pango" \
  "media-libs/fontconfig  # deps pango" \
  "media-libs/harfbuzz2  # deps pango" \
  "media-libs/libjpeg-turbo  # deps gdk-pixbuf" \
  "media-libs/libpng  # deps gdk-pixbuf" \
  "media-libs/tiff  # deps gdk-pixbuf" \
  "net-misc/curl" \
  "sys-apps/util-linux" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/gettext" \
  "sys-devel/m4  # required for ninja" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps glib" \
  "x11-libs/cairo  # deps pango" \
  "x11-libs/libx11  # deps pango,gdk-pixbuf" \
  "x11-libs/libxau  # deps pango,gdk-pixbuf" \
  "x11-libs/libxcb  # deps pango,gdk-pixbuf" \
  "x11-libs/libxdmcp  # deps pango,gdk-pixbuf" \
  "x11-libs/libxext  # deps pango" \
  "x11-libs/libxft  # deps pango" \
  "x11-libs/libxrender  # deps pango" \
  "x11-libs/pixman  # deps pango" \
  "x11-libs/gdk-pixbuf" \
  "x11-libs/pango" \
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

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-flags -O2 -fno-stack-protector -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  meson setup \
    -Dprefix="${EPREFIX%/}/usr" \
    -Dbindir="${EPREFIX%/}/bin" \
    -Dlibdir="/$(get_libdir)" \
    -Dwrap_mode="nodownload" \
    -Dbuildtype="release" \
    -Ddep11="true" \
    -Dbuilder="true" \
    -Drpm="false" \
    -Dalpm="false" \
    -Dfonts=$(usex 'fonts' true false) \
    -Dstemmer=$(usex 'stemmer' true false) \
    -Dintrospection=$(usex 'introspection' true false) \
    -Dman=$(usex 'man' true false) \
    -Dstrip=$(usex 'strip' true false) \
    "${BUILD_DIR}/build" "${BUILD_DIR}" \
    || die "meson setup... error"

  ninja -j "$(nproc)" -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${INSTALL_DIR}" meson install --no-rebuild -C "${BUILD_DIR}/build" || die "meson install... error"

  cd "${ED}/" || die "install dir: not found... error"

  rm -r -- "usr/share/bash-completion/" "usr/share/installed-tests/" "usr/share/locale/"

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'stest' && { bin/${PROG} --version || die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
