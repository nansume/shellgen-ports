#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-13 10:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs -upx +patch -doc -xstub -diet +musl +stest +strip +x32

export USER XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="(OTR) Messaging allows you to have private conversations over instant messaging"
HOMEPAGE="http://www.cypherpunks.ca/otr/"
LICENSE="GPL-2"
DOCS="AUTHORS ChangeLog NEWS README"
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="4.0.2"
SRC_URI="
  http://www.cypherpunks.ca/otr/${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/x11-plugins/${PN}/files/${PN}-${PV}-dont-clobber-fortify-source.patch
"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-static -static-libs +shared -doc (+musl) +stest +strip"
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
WORKDIR=${BUILD_DIR}
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
  "app-accessibility/at-spi2-core  # deps for pidgin" \
  "app-text/aspell  # deps for pidgin" \
  "app-text/enchant1  # deps for pidgin" \
  "app-text/gtk2spell  # deps for pidgin" \
  "dev-lang/perl  # required for autotools" \
  "dev-libs/atk  # deps for pidgin" \
  "dev-libs/expat  # deps for pidgin,intltool" \
  "dev-libs/fribidi  # deps for pidgin" \
  "dev-libs/glib  # deps for pidgin" \
  "dev-libs/gmp  # deps for pidgin" \
  "dev-libs/libffi  # deps for pidgin" \
  "dev-libs/libgcrypt  # deps libotr" \
  "dev-libs/libgpg-error  # deps libotr" \
  "dev-libs/libxml2  # for update-mime-database" \
  "dev-libs/libtasn1  # deps for pidgin" \
  "dev-libs/libunistring  # deps for pidgin" \
  "dev-libs/nettle  # deps for pidgin" \
  "dev-libs/pcre  # deps for pidgin" \
  "dev-perl/perl-xml-parser  # required for intltool" \
  "dev-util/intltool" \
  "dev-util/pkgconf" \
  "media-libs/freetype  # deps for pidgin" \
  "media-libs/fontconfig  # deps for pidgin" \
  "media-libs/harfbuzz2  # deps for pidgin" \
  "media-libs/libjpeg-turbo  # deps for pidgin" \
  "media-libs/libpng  # deps for pidgin" \
  "media-libs/tiff  # deps for pidgin" \
  "net-libs/gnutls  # deps for pidgin" \
  "net-libs/libotr" \
  "sys-apps/file" \
  "sys-devel/autoconf  # required for autotools" \
  "sys-devel/automake  # required for autotools" \
  "sys-devel/autoconf-archive" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/gettext  # required for intltool" \
  "sys-devel/libtool  # required for autotools" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps for pidgin" \
  "x11-base/xorg-proto  # deps for pidgin" \
  "x11-libs/cairo  # deps for pidgin" \
  "x11-libs/libice  # deps for pidgin" \
  "x11-libs/libsm  # deps for pidgin" \
  "x11-libs/libx11  # deps for pidgin" \
  "x11-libs/libxau  # deps for pidgin" \
  "x11-libs/libxcb  # deps for pidgin" \
  "x11-libs/libxcursor  # deps for pidgin" \
  "x11-libs/libxdmcp  # deps for pidgin" \
  "x11-libs/libxext  # deps for pidgin" \
  "x11-libs/libxfixes  # deps for pidgin" \
  "x11-libs/libxft  # deps for pidgin" \
  "x11-libs/libxrender  # deps for pidgin" \
  "x11-libs/libxscrnsaver  # deps for pidgin" \
  "x11-libs/pango  # deps for pidgin" \
  "x11-libs/pixman  # deps for pidgin" \
  "x11-libs/gdk-pixbuf  # deps for pidgin" \
  "x11-libs/gtk2  # deps for pidgin" \
  "net-im/pidgin  # after install it pkg to all other get error" \
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

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/${PN}-4.0.2-dont-clobber-fortify-source.patch

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc$(usex static ' --static')"
  CXX="g++$(usex static ' --static')"

  use 'strip' && INSTALL_OPTS="install-strip"

  test -x "/bin/perl" && autoreconf --install

  ./configure \
    --prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  find "$(get_libdir)/" -type f -name "*.la" -delete || die

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
