#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-04-15 01:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# usr/ports/x11-libs/gtk2-directfb/gtk+-directfb-2.18.7-r666.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Gimp ToolKit + (directfb target)"
HOMEPAGE="http://www.gtk.org/"
LICENSE="LGPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PV="2.18.7"
SLOT="2"
SRC_URI="
  https://download.gnome.org/sources/gtk+/${PV%.*}/gtk+-${PV}.tar.bz2 -> gtk-${PV}.tar.bz2
  http://localhost/gtk+-directfb-2.18.7_01-G_CONST_RETURN.diff
  http://localhost/gtk+-directfb-2.18.7_02-demos_fix.diff
  http://localhost/gtk+-directfb-2.18.7_03-libpng16.diff
  #http://localhost/gtk+-2.14.3-limit-gtksignal-includes.patch
  #http://localhost/gtk+-2.8.0-multilib.patch
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
IUSE="-aqua -cups -debug +jpeg -jpeg2k +tiff +png -samples -test"
IUSE="${IUSE} +static-libs +shared -doc (+musl) +stest +strip"
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
ZCOMP="bunzip2"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN/[0-9]-directfb/+}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
PROG="gtk-update-icon-cache"

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
  "app-accessibility/at-spi2-core" \
  "dev-lang/perl  # required for autotools" \
  "dev-lang/python38" \
  "dev-libs/atk" \
  "dev-libs/directfb" \
  "dev-libs/expat  # for fontconfig or python bundled" \
  "dev-libs/fribidi  # for pango (required remove)" \
  "dev-libs/glib69" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libxml2-1  # for gettext" \
  "dev-libs/pcre  # optional (internal pcre glib-2.68.4)" \
  "dev-util/pkgconf" \
  "media-libs/freetype" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz2  # for pango" \
  "media-libs/libjpeg-turbo1  # for gdk-pixbuf or bundled-libs" \
  "media-libs/libpng  # for pango or bundled-libs" \
  "media-libs/tiff  # for gdk-pixbuf" \
  "sys-apps/file" \
  "sys-devel/autoconf  # required for autotools" \
  "sys-devel/automake  # required for autotools" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/gettext  # required for autotools (optional)" \
  "sys-devel/libtool  # required for autotools" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl  # testing" \
  "sys-libs/musl0" \
  "sys-libs/zlib  # for glib or bundled-libs" \
  "x11-base/xorg-proto" \
  "x11-libs/cairo0  # optional" \
  "x11-libs/gdk-pixbuf" \
  "x11-libs/libice" \
  "x11-libs/libsm" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxcursor" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxfixes" \
  "x11-libs/libxft  # optional or --disable-xft" \
  "#x11-libs/libxinerama  # optional" \
  "x11-libs/libxrender # for xft (optional)" \
  "x11-libs/pango" \
  "x11-libs/pixman  # for cairo" \
  "x11-misc/shared-mime-info  # for gdk-pixbuf (testing)" \
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

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  export EROOT_PREFIX="/$(get_libdir)/dfb"

  patch -p1 -E < "${FILESDIR}"/gtk+-directfb-2.18.7_01-G_CONST_RETURN.diff
  patch -p1 -E < "${FILESDIR}"/gtk+-directfb-2.18.7_02-demos_fix.diff  # FIX: <demos> build failed.
  patch -p1 -E < "${FILESDIR}"/gtk+-directfb-2.18.7_03-libpng16.diff   # FIX: <png pixbuf> build failed.
  #patch -p1 -E < "${FILESDIR}"/gtk+-2.8.0-multilib.patch
  #patch -p1 -E < "${FILESDIR}"/gtk+-2.14.3-limit-gtksignal-includes.patch

strip_builddir() {
  local rule=$1
  shift
  local directory=$1
  shift
  sed -e "s/^\(${rule} =.*\)${directory}\(.*\)$/\1\2/" -i $@ \
   || die "Could not strip director ${directory} from build."
}

  # FIX: <demos> build failed.
  #if ! use 'examples'; then
  #  # don't waste time building demos
  #  strip_builddir SRC_SUBDIRS demos Makefile.am Makefile.in
  #fi

  ./configure \
    --prefix="${EROOT_PREFIX}" \
    --sysconfdir="${EROOT_PREFIX}"/etc \
    --libdir="${EROOT_PREFIX}/$(get_libdir)" \
    --includedir="${EROOT_PREFIX}"/usr/include \
    --datarootdir="${EROOT_PREFIX}"/usr/share \
    --datadir="${EROOT_PREFIX}"/usr/share \
    --mandir="${EROOT_PREFIX}"/usr/share/man \
    --host=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
    --build=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
    --with-gdktarget=directfb \
    --without-x \
    $(usex !png --without-libpng) \
    $(use_with 'jpeg' libjpeg) \
    $(use_with 'jpeg2k' libjasper) \
    $(use_with 'tiff' libtiff) \
    $(use_enable 'cups' cups auto) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  rm -r -- "${EROOT_PREFIX#/}/usr/share/man/"
  for D in "${EROOT_PREFIX#/}/$(get_libdir)/locale/"*; do
    case ${D##*/} in ''|et|ja|ru) continue;; esac
    rm -r -- "${D:?}"
  done

  find "${EROOT_PREFIX#/}/$(get_libdir)/" -type f -name "*.la" -delete || die

  mkdir -m 0755 -- "$(get_libdir)/pkgconfig/"

  cp -n "${EROOT_PREFIX#/}/$(get_libdir)/pkgconfig"/*directfb* -t "$(get_libdir)/pkgconfig/"

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/${EROOT_PREFIX#/}/$(get_libdir)"

  use 'stest' && { ${EROOT_PREFIX#/}/bin/${PROG} --version || : die "binary work... error";}
  ldd "${EROOT_PREFIX#/}/bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz