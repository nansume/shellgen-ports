#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-07 13:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Library providing a virtual terminal emulator widget"
HOMEPAGE="https://gitlab.gnome.org/GNOME/vte/"
LICENSE="LGPL-3+ GPL-3+"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="0.76.3"  # bug: gcc9 no support: c++20
PV="0.64.2"  # bug: ModuleNotFoundError: No module named <dataclasses>
PV="0.62.3"
I="data.gpo.zugaina.org/gentoo/x11-libs/vte"
SRC_URI="
  https://download.gnome.org/sources/vte/${PV%.*}/vte-${PV}.tar.xz
  #http://${I}/files/vte-0.64.1-meson-Find-python-explicitly-to-honor-downstream-pyt.patch
  http://data.gpo.zugaina.org/gentoo/x11-libs/vte/files/vte-0.76.3-stdint.patch
  http://data.gpo.zugaina.org/gentoo/x11-libs/vte/files/vte-0.66.2-musl-W_EXITCODE.patch
  #https://dev.gentoo.org/~pacho/${PN}/${PN}-${PV}-command-notify.patch.xz
  #https://dev.gentoo.org/~pacho/${PN}/${PN}-${PV}-a11y-implement-GtkAccessibleText.patch.xz
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
IUSE="-crypt -debug -gtk-doc -icu -introspection -systemd -vala -vanilla"
IUSE="${IUSE} -static-libs +shared -doc (+musl) +stest +strip"
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
  "app-accessibility/at-spi2-atk  # for atk" \
  "app-accessibility/at-spi2-core  # for atk" \
  "app-arch/lz4" \
  "app-text/libpaper  # required for cups (optional)" \
  "dev-build/meson6  # build tool" \
  "dev-lang/python3  # for meson" \
  "dev-libs/atk" \
  "dev-libs/expat  # python bundled" \
  "dev-libs/fribidi" \
  "dev-libs/glib" \
  "#dev-libs/icu  # icu" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libxml2" \
  "dev-libs/pcre  # for glib-2.64" \
  "dev-libs/pcre2" \
  "dev-python/importlib-resources  # for meson (build tool)" \
  "dev-python/mako" \
  "dev-python/py3-setuptools  # for meson (build tool)" \
  "dev-python/zipp  # for meson (build tool)" \
  "dev-util/cmake  # it optional?" \
  "dev-util/pkgconf" \
  "dev-util/ninja  # for meson (build tool)" \
  "media-libs/freetype" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz2  # for pango" \
  "media-libs/libepoxy" \
  "media-libs/libjpeg-turbo  # for gdk-pixbuf or bundled-libs" \
  "media-libs/libpng  # for pango or bundled-libs" \
  "media-libs/mesa  # required for libepoxy (opengl)" \
  "media-libs/tiff  # for gdk-pixbuf" \
  "#net-libs/gnutls  # crypt" \
  "sys-apps/dbus  # for atk" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/m4  # required for ninja" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib  # for glib" \
  "x11-base/xorg-proto" \
  "x11-libs/cairo  # optional" \
  "x11-libs/gdk-pixbuf" \
  "x11-libs/gtk3" \
  "x11-libs/libdrm  # for mesa (optional)" \
  "x11-libs/libice" \
  "x11-libs/libpciaccess  # for mesa (optional)" \
  "x11-libs/libsm" \
  "x11-libs/libvdpau  # for mesa (optional)" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxcursor" \
  "x11-libs/libxcomposite" \
  "x11-libs/libxdamage" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxfixes" \
  "x11-libs/libxft  # optional or --disable-xft" \
  "x11-libs/libxi" \
  "x11-libs/libxrandr  # for mesa (optional)" \
  "x11-libs/libxrender # for xft (optional)" \
  "x11-libs/libxshmfence  # for mesa (optional)" \
  "x11-libs/libxxf86vm  # for mesa (optional)" \
  "x11-libs/libxt  # for atk" \
  "x11-libs/pango" \
  "x11-libs/pixman  # for cairo" \
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

  #patch -p1 -E < "${FILESDIR}"/${PN}-0.64.1-meson-Find-python-explicitly-to-honor-downstream-pyt.patch
  #patch -p1 -E < "${FILESDIR}/${PN}-0.76.3-stdint.patch"
  use 'musl' && gpatch -p1 -E < "${FILESDIR}"/${PN}-0.66.2-musl-W_EXITCODE.patch

  # -Ddebugg option enables various debug support via VTE_DEBUG, but also ggdb3; strip the latter
  sed -e '/ggdb3/d' -i meson.build || die
  #sed -e 's/vte_gettext_domain = vte_api_name/vte_gettext_domain = vte_gtk3_api_name/' -i meson.build || die

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
    -Dbuildtype="release" \
    $(usex 'strip' --strip) \
    -Da11y="true" \
    -Ddebug=$(usex 'debug' true false) \
    -Dgir=$(usex 'introspection' true false) \
    -Dfribidi="true" \
    $(usex 'glade' -Dglade="true") \
    -Dgnutls=$(usex 'crypt' true false) \
    -Dgtk3="true" \
    -Dgtk4="false" \
    -Dicu="false" \
    -D_systemd="false" \
    -Dvapi="false" \
    -Ddocs="false" \
    "${BUILD_DIR}/build" \
    || die "meson setup... error"

  ninja -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${INSTALL_DIR}" meson install --no-rebuild -C "${BUILD_DIR}/build" || die "meson install... error"

  : einstalldocs

  cd "${ED}/" || die "install dir: not found... error"

  if use 'gtk-doc'; then
    mkdir -pm '0755' -- usr/share/gtk-doc/html/ || die
    mv -n usr/share/doc/${PN}-1.0 -t usr/share/gtk-doc/html/ || die
  fi

  # fix: meson wrong the pkgconfig
  sed \
    -e "1s|^prefix=.*|prefix=|;t" \
    -e "2s|^libdir=.*|libdir=/$(get_libdir)|;t" \
    -e "3s|^includedir=.*|includedir=/usr/include|;t" \
    -i $(get_libdir)/pkgconfig/${PN}*.pc || die

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
