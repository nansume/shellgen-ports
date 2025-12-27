#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-05-01 20:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/x11-libs/libwnck/libwnck-43.0-r1.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="A window navigation construction kit"
HOMEPAGE="https://developer.gnome.org/libwnck/stable/"
LICENSE="LGPL-2+"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="43.0"
PV="40.1"
PV="3.36.0"
PV="3.32.0"
PV="3.30.0"
SLOT="3"
SRC_URI="
  https://download.gnome.org/sources/libwnck/${PV%.*}/${PN}-${PV}.tar.xz
  http://data.gpo.zugaina.org/gentoo/x11-libs/${PN}/files/${PN}-43.0-xres-extension.patch
  http://data.gpo.zugaina.org/gentoo/x11-libs/${PN}/files/${PN}-43.0-segfault_in_invalidate_icons.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-gtk-doc -introspection -startup-notification +tools"
IUSE="${IUSE} +static-libs +shared +nopie -doc (+musl) +stest +strip"
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
PROG=${PN}

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
  "app-text/libpaper  # required for cups (optional)" \
  "#dev-build/meson7  # build tool" \
  "dev-build/muon  # alternative for meson" \
  "dev-build/samurai  # alternative for ninja" \
  "dev-lang/python38  # deps meson" \
  "dev-libs/atk" \
  "dev-libs/expat  # deps meson,python" \
  "dev-libs/fribidi  # for pango (required remove)" \
  "dev-libs/glib74" \
  "dev-libs/libffi  # deps glib" \
  "dev-libs/pcre2  # deps glib74" \
  "#dev-util/cmake  # it optional?" \
  "dev-util/pkgconf" \
  "media-libs/freetype" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz2-1  # for pango" \
  "media-libs/libepoxy" \
  "media-libs/libjpeg-turbo3  # for gdk-pixbuf or bundled-libs" \
  "media-libs/libpng  # for pango or bundled-libs" \
  "media-libs/mesa  # required for libepoxy (opengl)" \
  "media-libs/tiff  # for gdk-pixbuf" \
  "sys-apps/dbus  # for atk" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/m4  # required for ninja" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps glib" \
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
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"
  # https://gitlab.gnome.org/GNOME/libwnck/-/issues/154
  #patch -p1 -E < "${FILESDIR}/${PN}-43.0-xres-extension.patch"
  # https://gitlab.gnome.org/GNOME/libwnck/-/issues/155
  #patch -p1 -E < "${FILESDIR}/${PN}-43.0-segfault_in_invalidate_icons.patch"

  # Don't collide with SLOT=1 with USE=tools
  #sed -e "s|executable(prog|executable(prog + '-3'|" -i libwnck/meson.build || die

  meson setup \
    --default-library=$(usex 'shared' both static) \
    -D prefix="/" \
    -D bindir="bin" \
    -D libdir="$(get_libdir)" \
    -D includedir="usr/include" \
    -D datadir="usr/share" \
    -D wrap_mode="nodownload" \
    -D buildtype="release" \
    -D deprecation_flags=false \
    -D install_tools=$(usex 'tools' true false) \
    -D startup_notification=$(usex 'startup-notification' enabled disabled) \
    -D introspection=$(usex 'introspection' enabled disabled) \
    -D gtk_doc=$(usex 'gtk-doc' true false) \
    -D b_pie="false" \
    -D strip=$(usex 'strip' true false) \
    "${BUILD_DIR}/build" "${BUILD_DIR}" \
    || die "meson setup... error"

  ninja -j "$(nproc)" -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${ED}" meson -C "${BUILD_DIR}/build" install -d "${ED}" --no-rebuild -C "${BUILD_DIR}/build" \
    || die "meson install... error"

  cd "${ED}/" || die "install dir: not found... error"

  grep '${prefix}' < $(get_libdir)/pkgconfig/${PN}.pc
  sed -e 's|${prefix}||' -i $(get_libdir)/pkgconfig/*${PN#lib}*.pc || : die

  rm -vr -- "usr/share/doc/" "usr/share/bash-completion/" "usr/share/installed-tests/" "usr/share/locale/"

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  #use 'stest' && { bin/${PROG} --version || : die "binary work... error";}
  #ldd "bin/${PROG}" || { use 'static' && true || : die "library deps work... error";}
  ldd "$(get_libdir)"/lib*${PN}*.so || : die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz