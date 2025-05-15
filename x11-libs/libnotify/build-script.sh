#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-07 13:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="A library for sending desktop notifications"
HOMEPAGE="https://gitlab.gnome.org/GNOME/libnotify"
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
PV="0.8.3"
SRC_URI="https://download.gnome.org/sources/libnotify/0.8/libnotify-0.8.3.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
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
  "#app-text/docbook-xsl-ns-stylesheets" \
  "dev-build/meson5  # build tool" \
  "dev-lang/python3  # for meson" \
  "dev-libs/expat  # python bundled" \
  "dev-libs/glib  # glib-2.68.4" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/pcre  # for glib-2.68.4" \
  "dev-libs/libxslt" \
  "dev-python/importlib-resources  # for meson (build tool)" \
  "dev-python/mako" \
  "dev-python/py3-setuptools  # for meson (build tool)" \
  "dev-python/zipp  # for meson (build tool)" \
  "dev-util/cmake" \
  "dev-util/pkgconf" \
  "dev-util/ninja  # for meson (build tool)" \
  "media-libs/libjpeg-turbo" \
  "media-libs/libpng" \
  "media-libs/tiff" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/m4  # required for ninja" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # for libpng,glib" \
  "x11-base/xorg-proto" \
  "x11-libs/gdk-pixbuf" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxdmcp" \
  "x11-misc/shared-mime-info" \
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

  mkdir -pm 0755 -- "${BUILD_DIR}/build/"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  meson setup \
    --prefix "${EPREFIX%/}/" \
    --bindir "bin" \
    --sbindir "sbin" \
    --sysconfdir "etc" \
    --libdir "$(get_libdir)" \
    --includedir "usr/include" \
    --libexecdir "usr/libexec" \
    --datadir "usr/share" \
    --localstatedir "var/lib" \
    --wrap-mode "nodownload" \
    --buildtype "release" \
    --strip \
    -Dintrospection="disabled" \
    -Dgtk_doc="false" \
    -Ddocbook_docs="disabled" \
    -Dman="false" \
    -Dtests="false" \
    "${BUILD_DIR}/build" \
    || die "meson setup... error"

  ninja -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${INSTALL_DIR}" meson install --no-rebuild -C "${BUILD_DIR}/build" || die "meson install... error"

  : einstalldocs

  cd "${ED}/" || die "install dir: not found... error"

  mv -n bin/notify-send bin/libnotify-notify-send || die #379941

  if use 'gtk-doc'; then
    mkdir -p usr/share/gtk-doc/html/ || die
    mv -n usr/share/doc/${PN}-1.0 usr/share/gtk-doc/html/ || die
  fi

  # fix: meson wrong the pkgconfig
  sed \
    -e "1s|^prefix=.*|prefix=|;t" \
    -e "2s|^libdir=.*|libdir=/$(get_libdir)|;t" \
    -e "3s|^includedir=.*|includedir=/usr/include|;t" \
    -i $(get_libdir)/pkgconfig/${PN}.pc || die

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
