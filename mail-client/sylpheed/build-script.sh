#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-28 12:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs -upx +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="A lightweight email client and newsreader"
HOMEPAGE="http://sylpheed.sraoss.jp/"
LICENSE="GPL-2+ LGPL-2.1+"
DOCS="AUTHORS ChangeLog* NEW* PLUGIN* README* TODO*"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="3.7.0"
SRC_URI="
  http://${PN}.sraoss.jp/${PN}/v${PV%.*}/${PN}-${PV}.tar.bz2
  http://data.gpo.zugaina.org/KBrown-pub/mail-client/sylpheed/files/sylpheed-tls-1.3.patch
  http://data.gpo.zugaina.org/KBrown-pub/mail-client/sylpheed/files/sylpheed-CVE-2021-37746.patch
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
IUSE="-crypt +ipv6 -ldap (-nls) -oniguruma -spell +ssl +xface"
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
  "app-accessibility/at-spi2-core" \
  "dev-libs/atk" \
  "dev-libs/expat  # for fontconfig or python bundled" \
  "dev-libs/fribidi  # for pango (required remove)" \
  "dev-libs/glib" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libxml2  # for gettext" \
  "dev-libs/pcre  # optional (internal pcre glib-2.68.4)" \
  "dev-libs/openssl3  # for depend to curl" \
  "dev-util/byacc  # alternative a bison" \
  "dev-util/intltool" \
  "dev-util/pkgconf" \
  "net-libs/liblockfile" \
  "net-misc/curl" \
  "media-libs/freetype" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz2  # for pango" \
  "media-libs/libjpeg-turbo  # for gdk-pixbuf or bundled-libs" \
  "media-libs/libpng  # for pango or bundled-libs" \
  "media-libs/tiff  # for gdk-pixbuf" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/lex" \
  "sys-devel/m4" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  "x11-base/xorg-proto" \
  "x11-libs/cairo  # optional" \
  "x11-libs/gdk-pixbuf" \
  "x11-libs/gtk2" \
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
  "x11-libs/libxrender # for xft (optional)" \
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

  inherit desktop xdg install-functions

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
    use 'static' && append-ldflags "-s -static --static"  # testing
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc$(usex static ' -static --static')"
  CXX="c++$(usex static ' -static --static')"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"
  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  patch -p1 -E < "${FILESDIR}/sylpheed-tls-1.3.patch"
  patch -p1 -E < "${FILESDIR}/sylpheed-CVE-2021-37746.patch"

  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'crypt' gpgme) \
    $(use_enable 'ipv6') \
    --disable-ldap \
    $(use_enable 'oniguruma') \
    $(use_enable 'spell' gtkspell) \
    $(use_enable 'ssl') \
    $(use_enable 'xface' compface) \
    --with-plugindir="${EPREFIX%/}"/$(get_libdir)/${PN}/plugins \
    --with-manualdir=/usr/share/doc/${PN}-${PV}/html/manual \
    --with-faqdir=/usr/share/doc/${PN}-${PV}/html/faq \
    --disable-updatecheck \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    --disable-rpath \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  doicon *.png
  domenu *.desktop

  cd plugin/attachment_tool
  make DESTDIR="${ED}" install-plugin
  docinto plugin/attachment_tool
  dodoc README

  cd "${ED}/" || die "install dir: not found... error"

  find "$(get_libdir)/" -name '*.la' -delete || die

  use 'doc' || { rm -vr -- \
    "usr/share/doc/${PN}-${PV}/html/faq/de/" \
    "usr/share/doc/${PN}-${PV}/html/faq/es/" \
    "usr/share/doc/${PN}-${PV}/html/faq/fr/" \
    "usr/share/doc/${PN}-${PV}/html/faq/it/"
  }

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'stest' && { bin/${PN} -v || : die "binary work... error";}

  ldd "bin/${PN}" || { use 'static' && true;}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
