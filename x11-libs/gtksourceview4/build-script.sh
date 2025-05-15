#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-04 18:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs -nopie -patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="A text widget implementing syntax highlighting and other features"
HOMEPAGE="https://wiki.gnome.org/Projects/GtkSourceView"
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
PN=${PN%[0-9]}
PV="4.8.4"
SRC_URI="https://download.gnome.org/sources/gtksourceview/4.8/gtksourceview-4.8.4.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-glade -gtk-doc -introspection -vala -doc (+musl) +stest +strip"
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
CMAKE_PREFIX_PATH="/${LIB_DIR}/cmake"

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

# required fix: <glib-compile-schemas: not found>
pkginst \
  "app-accessibility/at-spi2-core" \
  "app-accessibility/at-spi2-atk  # required" \
  "dev-build/meson5  # build tool" \
  "dev-lang/python3  # for meson" \
  "dev-libs/atk" \
  "dev-libs/expat  # for fontconfig or python bundled" \
  "dev-libs/fribidi  # for pango (required remove)" \
  "dev-libs/glib" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libxml2  # for gettext" \
  "dev-libs/libxslt  # required" \
  "dev-libs/pcre  # optional (internal pcre glib-2.68.4)" \
  "dev-libs/libcroco  # deps librsvg" \
  "dev-python/importlib-resources  # for meson (build tool)" \
  "dev-python/mako" \
  "dev-python/py3-setuptools  # for meson (build tool)" \
  "dev-python/zipp  # for meson (build tool)" \
  "dev-util/cmake  # optional" \
  "dev-util/pkgconf" \
  "dev-util/ninja  # for meson (build tool)" \
  "media-libs/libepoxy  # required" \
  "media-libs/freetype" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz2  # for pango" \
  "media-libs/libjpeg-turbo  # for gdk-pixbuf or bundled-libs" \
  "media-libs/libpng  # for pango or bundled-libs" \
  "media-libs/mesa  # deps libepoxy" \
  "media-libs/tiff  # for gdk-pixbuf" \
  "sys-apps/dbus  # deps at-spi2-atk" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/m4  # required for ninja" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl  # testing" \
  "sys-libs/musl" \
  "sys-libs/zlib  # for glib or bundled-libs" \
  "x11-base/xorg-proto  # deps for gtk" \
  "x11-libs/cairo  # deps for gtk" \
  "x11-libs/libdrm  # for mesa" \
  "x11-libs/libpciaccess  # for mesa" \
  "x11-libs/libvdpau  # for mesa" \
  "x11-libs/libice  # deps for gtk" \
  "x11-libs/libsm  # deps for gtk" \
  "x11-libs/libx11  # deps for gtk" \
  "x11-libs/libxau  # deps for gtk" \
  "x11-libs/libxcb  # deps for gtk" \
  "x11-libs/libxcomposite  # deps for gtk" \
  "x11-libs/libxcursor  # deps for gtk" \
  "x11-libs/libxdamage  # required" \
  "x11-libs/libxdmcp  # deps for gtk" \
  "x11-libs/libxext  # deps for gtk" \
  "x11-libs/libxfixes  # deps for gtk" \
  "x11-libs/libxft  # deps for gtk" \
  "x11-libs/libxi  # required" \
  "x11-libs/libxrandr  # required" \
  "x11-libs/libxrender  # deps for gtk" \
  "x11-libs/libxshmfence  # for mesa" \
  "x11-libs/libxxf86vm  # for mesa" \
  "x11-libs/libxt  # deps at-spi2-atk" \
  "x11-libs/pango  # deps for gtk" \
  "x11-libs/pixman  # deps for gtk" \
  "x11-libs/gdk-pixbuf  # deps for gtk2" \
  "x11-libs/gtk2" \
  "x11-libs/gtk3" \
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

  CC="cc" CXX="c++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  mkdir -pm 0755 -- "${BUILD_DIR}/build/"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  meson setup \
    --prefix "${EPREFIX%/}/" \
    --libdir "$(get_libdir)" \
    --includedir "usr/include" \
    --datadir "usr/share" \
    --wrap-mode "nodownload" \
    --buildtype "release" \
    --strip \
    -Dglade_catalog="false" \
    -Dgir="false" \
    -Dvapi="false" \
    -Dgtk_doc="false" \
    -Dinstall_tests=false \
    "${BUILD_DIR}/build" \
    || die "meson setup... error"

  ninja -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${INSTALL_DIR}" meson install --no-rebuild -C "${BUILD_DIR}/build" || die "meson install... error"

  cd "${ED}/" || die "install dir: not found... error"

  # fix: meson wrong the pkgconfig
  sed \
    -e "1s|^prefix=.*|prefix=|;t" \
    -e "2s|^libdir=.*|libdir=/$(get_libdir)|;t" \
    -e "3s|^includedir=.*|includedir=/usr/include|;t" \
    -i ${ED}/$(get_libdir)/pkgconfig/${PN}*.pc || die

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz