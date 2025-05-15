#!/bin/sh
# Copyright (C) 2024-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2024-09-27 11:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# Warning! Required imlib2[x11] build with x11 support.

# http://data.gpo.zugaina.org/gentoo/media-gfx/qiv/qiv-2.3.3.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Quick Image Viewer"
HOMEPAGE="https://spiegl.de/qiv/ https://codeberg.org/ciberandy/qiv"
LICENSE="GPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="2.3.3"
SRC_URI="https://spiegl.de/qiv/download/${PN}-${PV}.tgz -> ${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+exif -lcms -magic -doc (+musl) +stest +strip"
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
ZCOMP="gunzip"
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
  "dev-lang/python38" \
  "dev-libs/atk" \
  "dev-libs/expat  # for fontconfig or python bundled" \
  "dev-libs/fribidi  # for pango (required remove)" \
  "dev-libs/glib74" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libxml2-1  # for gettext" \
  "dev-libs/pcre2  # optional (internal pcre glib-2.68.4)" \
  "dev-util/intltool" \
  "dev-util/pkgconf" \
  "media-libs/freetype" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz2-1  # for pango" \
  "media-libs/imlib2  # required: imlib2[X]" \
  "media-libs/lcms2  # lcms (optional)" \
  "media-libs/libexif  # exif (optional)" \
  "media-libs/libjpeg-turbo3  # lcms (optional)" \
  "media-libs/libpng  # for pango or bundled-libs" \
  "media-libs/tiff  # lcms (optional)" \
  "sys-apps/file  # magic (optional)" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "#sys-devel/lex  # alternative a flex" \
  "#sys-devel/libtool  # required for autotools" \
  "#sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps: glib,png" \
  "x11-base/xorg-proto  # deps for gtk" \
  "x11-libs/cairo  # deps for gtk" \
  "#x11-libs/gtksourceview4" \
  "#x11-libs/libdrm  # for mesa" \
  "#x11-libs/libpciaccess  # for mesa" \
  "#x11-libs/libvdpau  # for mesa" \
  "x11-libs/libice  # deps for gtk" \
  "x11-libs/libsm  # deps for gtk" \
  "x11-libs/libx11  # deps for gtk" \
  "x11-libs/libxau  # deps for gtk" \
  "x11-libs/libxcb  # deps for gtk" \
  "#x11-libs/libxcomposite  # deps for gtk" \
  "x11-libs/libxcursor  # deps for gtk" \
  "#x11-libs/libxdamage  # required" \
  "x11-libs/libxdmcp  # deps for gtk" \
  "x11-libs/libxext  # deps for gtk" \
  "x11-libs/libxfixes  # deps for gtk" \
  "x11-libs/libxft  # deps for gtk" \
  "#x11-libs/libxi  # required" \
  "#x11-libs/libxrandr  # required" \
  "x11-libs/libxrender  # deps for gtk" \
  "#x11-libs/libxshmfence  # for mesa" \
  "#x11-libs/libxxf86vm  # for mesa" \
  "#x11-libs/libxt  # deps at-spi2-atk" \
  "x11-libs/pango  # deps for gtk" \
  "x11-libs/pixman  # deps for gtk" \
  "x11-libs/gdk-pixbuf  # deps for gtk2" \
  "x11-libs/gtk2" \
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

  inherit desktop xdg install-functions toolchain-funcs

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

  sed -e 's:$(CC) $(CFLAGS):$(CC) $(LDFLAGS) $(CFLAGS):' -i Makefile || die

  use 'exif'  || sed -e 's/^EXIF =/#\0/'  -i Makefile || die
  use 'lcms'  || sed -e 's/^LCMS =/#\0/'  -i Makefile || die
  use 'magic' || sed -e 's/^MAGIC =/#\0/' -i Makefile || die

  make -j "$(nproc)" CC="${CC}" CFLAGS="${CFLAGS}" || die "Failed make build"

  : make DESTDIR="${ED}" install || : die "make install... error"
  mkdir -pm 0755 -- "${ED}/bin/"
  mv -n ${PN} -t "${ED}/bin/"
  : doman qiv.1
  : dodoc Changelog contrib/qiv-command.example README README.TODO
  domenu qiv.desktop
  doicon qiv.png
  printf %s\\n "Install: ${PN}... ok"

  cd "${ED}/" || die "install dir: not found... error"

  strip --verbose --strip-all "bin/${PN}"

  use 'stest' && { bin/${PN} --version || die "binary work... error";}
  ldd "bin/${PN}" || die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz