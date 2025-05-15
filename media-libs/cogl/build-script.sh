#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-04-29 10:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/media-libs/cogl/cogl-1.22.8-r3.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH _LIBS _LDCONFIG

DESCRIPTION="A library for using 3D graphics hardware to draw pretty pictures"
HOMEPAGE="https://www.cogl3d.org/"
LICENSE="MIT BSD"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PV="1.22.8"
SRC_URI="
  https://download.gnome.org/sources/cogl/${PV%.*}/${PN}-${PV}.tar.xz
  http://data.gpo.zugaina.org/gentoo/media-libs/cogl/files/cogl-1.22.8-slibtool.patch
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
IUSE="-debug -examples -gles2 -gstreamer -introspection +kms +opengl +pango -wayland"
IUSE="${IUSE} -static +static-libs +shared -doc (+musl) +stest +strip"
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
  "dev-lang/python38  # required for glib74" \
  "dev-libs/expat  # for freetype,python" \
  "dev-libs/fribidi  # required remove" \
  "dev-libs/glib74" \
  "dev-libs/gobject-introspection  # BUG: with it no build" \
  "dev-libs/libffi  # required for glib" \
  "dev-libs/lzo  # optional" \
  "dev-libs/pcre2  # required for glib74" \
  "dev-util/pkgconf" \
  "media-libs/fontconfig" \
  "media-libs/freetype" \
  "media-libs/harfbuzz2-0" \
  "media-libs/libpng" \
  "media-libs/tiff" \
  "media-libs/mesa  # optional" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl  # optional, testing" \
  "sys-libs/musl" \
  "sys-libs/zlib  # for libpng" \
  "x11-base/xorg-proto" \
  "x11-libs/cairo" \
  "x11-libs/libdrm  # for mesa" \
  "x11-libs/libpciaccess  # for mesa" \
  "x11-libs/libvdpau  # for mesa" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxcomposite" \
  "x11-libs/libxdamage  # for mesa" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxfixes  # for mesa" \
  "x11-libs/libxrandr  # for mesa" \
  "x11-libs/libxrender" \
  "x11-libs/libxshmfence  # for mesa" \
  "x11-libs/libxxf86vm  # for mesa" \
  "x11-libs/gdk-pixbuf" \
  "x11-libs/pango  # required for librsvg" \
  "x11-libs/pixman" \
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
  if use !shared && use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  # bug #943759
  append-cflags -std=gnu17

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-slibtool.patch

  # Do not build examples
  sed -e "s/^\(SUBDIRS +=.*\)examples\(.*\)$/\1\2/" -i Makefile.am Makefile.in || die

  sed \
   -e "s/^\(SUBDIRS =.*\)test-fixtures\(.*\)$/\1\2/" \
   -e "s/^\(SUBDIRS +=.*\)tests\(.*\)$/\1\2/" \
   -e "s/^\(.*am__append.* \)tests\(.*\)$/\1\2/" \
   -i Makefile.am Makefile.in || die

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --disable-examples-install \
    --disable-maintainer-flags \
    --enable-cairo \
    --enable-deprecated \
    --enable-gdk-pixbuf \
    --enable-glib \
    $(use_enable 'debug') \
    $(use_enable 'opengl' glx) \
    $(use_enable 'opengl' gl) \
    $(use_enable 'gles2') \
    $(use_enable 'gles2' cogl-gles2) \
    $(use_enable 'gles2' xlib-egl-platform) \
    $(usex 'gles2' --with-default-driver=$(usex 'opengl' gl gles2) ) \
    $(use_enable 'gstreamer' cogl-gst)    \
    $(use_enable 'introspection') \
    $(use_enable 'kms' kms-egl-platform) \
    $(use_enable 'pango' cogl-pango) \
    --disable-unit-tests \
    --disable-wayland-egl-platform \
    --disable-wayland-egl-server \
    --disable-profile \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    --disable-nls \
    --disable-rpath \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || : die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  # Remove silly examples-data directory
  rm -v -r -- "usr/share/cogl/examples-data/" "usr/share/"


  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  ldd "$(get_libdir)"/lib${PN}.so || die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz