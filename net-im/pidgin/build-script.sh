#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-12 23:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs -upx -patch -doc -xstub -diet +musl +stest +strip +x32

export USER XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="GTK Instant Messenger client"
HOMEPAGE="https://pidgin.im/"
LICENSE="GPL-2"
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="2.14.13"
SRC_URI="https://downloads.sourceforge.net/${PN}/${PN}-${PV}.tar.bz2"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-static -static-libs +shared -doc (+musl) +stest +strip"
IUSE="${IUSE} -aqua -dbus -debug -doc -eds -gadu +gnutls -groupwise -gstreamer"
IUSE="${IUSE} +gtk +gui -idn -meanwhile -ncurses -networkmanager"
IUSE="${IUSE} -nls -perl -pie -prediction -python -sasl +spell -tcl"
IUSE="${IUSE} -test -tk -v4l +xscreensaver -zephyr -zeroconf"
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

# Enable Default protocols
DEFAULT_PRPLS="irc,jabber,simple"

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
  "app-misc/ca-certificates  # required for gnutls" \
  "app-text/aspell  # spell?" \
  "#app-text/doxygen  # doc?" \
  "app-text/enchant1  # spell?" \
  "app-text/gtk2spell  # spell?" \
  "#dev-db/sqlite  # prediction?" \
  "#dev-lang/perl  # perl?" \
  "dev-lang/python3  # dbus?, for glib" \
  "#dev-lang/tcl  # tcl?" \
  "#dev-lang/tk  # tk?" \
  "dev-libs/atk" \
  "#dev-libs/check  # test?" \
  "#dev-libs/cyrus-sasl  # sasl?" \
  "#dev-libs/dbus-glib  # dbus?" \
  "dev-libs/expat  # for fontconfig" \
  "dev-libs/fribidi  # for pango (required remove)" \
  "dev-libs/glib" \
  "dev-libs/gmp  # for gnutls" \
  "dev-libs/libffi  # for glib" \
  "#dev-libs/libgnt  # ncurses?" \
  "dev-libs/libxml2  # for update-mime-database" \
  "dev-libs/libtasn1  # for gnutls" \
  "dev-libs/libunistring  # for gnutls" \
  "dev-libs/nettle  # for gnutls" \
  "dev-libs/pcre  # optional (internal pcre glib-2.68.4)" \
  "#dev-perl/perl-xml-parser  # perl?" \
  "#dev-python/dbus-python  # dbus?" \
  "#dev-util/intltool  # nls?" \
  "dev-util/pkgconf" \
  "media-libs/freetype" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz2  # for pango" \
  "media-libs/libjpeg-turbo  # for gdk-pixbuf or bundled-libs" \
  "media-libs/libpng  # for pango or bundled-libs" \
  "media-libs/tiff  # for gdk-pixbuf" \
  "#net-dns/libidn  # idn?" \
  "net-libs/gnutls  # gnutls?" \
  "#net-libs/libgadu  # gadu?" \
  "#net-libs/meanwhile  # meanwhile?" \
  "sys-apps/file" \
  "#sys-apps/dbus  # dbus?" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "#sys-devel/gettext  # nls?" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "#sys-libs/ncurses  # ncurses? [unicode]" \
  "sys-libs/zlib  # zlib? gnutls?, for libpng" \
  "x11-base/xorg-proto" \
  "x11-libs/cairo  # optional" \
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
  "x11-libs/libxscrnsaver  # xscreensaver?" \
  "x11-libs/pango" \
  "x11-libs/pixman  # for cairo" \
  "x11-libs/gdk-pixbuf" \
  "x11-libs/gtk2  # gtk?" \
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

  inherit autotools flag-o-matic install-functions

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

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

  # Stabilize things, for your own good
  : strip-flags
  : replace-flags -O? -O2
  use 'pie' && append-cflags -fPIE -pie

  use 'gadu'      && DEFAULT_PRPLS+=",gg"
  use 'groupwise' && DEFAULT_PRPLS+=",novell"
  use 'meanwhile' && DEFAULT_PRPLS+=",sametime"
  use 'zephyr'    && DEFAULT_PRPLS+=",zephyr"
  use 'zeroconf'  && DEFAULT_PRPLS+=",bonjour"

  # set variable to prevent configure script from calling gconftool-2
  GCONF_SCHEMA_INSTALL_SOURCE="/etc/gconf/schemas" \
  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-mono \
    --disable-fortify \
    --with-dynamic-prpls="${DEFAULT_PRPLS}" \
    --with-system-ssl-certs="${EPREFIX}/etc/ssl/certs/" \
    --x-includes="${EPREFIX}"/usr/include/X11 \
    $(use_enable 'dbus') \
    $(use_enable 'debug') \
    $(use_enable 'doc' doxygen) \
    $(use_enable 'gstreamer') \
    $(use_enable 'gtk' gtkui) \
    $(use_enable 'gtk' sm) \
    $(use_enable 'idn') \
    $(use_enable 'meanwhile') \
    $(use_enable 'networkmanager' nm) \
    $(use_enable 'ncurses' consoleui) \
    $(use_enable 'perl') \
    $(use_enable 'sasl' cyrus-sasl ) \
    $(use_enable 'tk') \
    $(use_enable 'tcl') \
    $(use_enable 'v4l' farstream) \
    $(use_enable 'v4l' gstreamer-video) \
    $(use_enable 'v4l' vv) \
    $(use_enable 'zeroconf' avahi) \
    $(use_with 'gstreamer' gstreamer 1.0) \
    $(usex 'gtk' --enable-nls $(use_enable 'nls') ) \
    $(use 'gtk' && use_enable 'eds' gevolution) \
    $(use 'gtk' && use_enable 'prediction' cap) \
    $(use 'gtk' && use_enable 'spell' gtkspell) \
    $(use 'gtk' && use_enable 'xscreensaver' screensaver) \
    --enable-gnutls=yes \
    --enable-nss=no \
    --with-gnutls-includes="${EPREFIX}/usr/include/gnutls" \
    --with-gnutls-libs="${EPREFIX}/usr/$(get_libdir)" \
    --without-python3 \
    $(use_enable 'shared') \
    --disable-static \
    $(use_enable 'nls') \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  # setting this here because we no longer use gnome2.eclass
  export GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL="1"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  if use 'gtk'; then
    # Fix tray paths for e16 (x11-wm/enlightenment) and other
    # implementations that are not compliant with new hicolor theme yet, #323355
    for d in 16 22 32 48 ; do
      pixmapdir="${ED}/usr/share/pixmaps/pidgin/tray/hicolor/${d}x${d}/actions"
      mkdir -m 0755 -- "${pixmapdir}/" || die
      cd "${pixmapdir}/" || die
      for f in ../status/*; do
        ln -s ${f} || die
      done
      cd "${BUILD_DIR}/" || die "builddir: not found... error"
    done
  fi
  #use perl && perl_delete_localpod

  #use dbus && python_fix_shebang ${ED}
  #if use python || use dbus ; then
  #  python_optimize
  #fi

  : dodoc ${DOCS} finch/plugins/pietray.py
  : docompress -x /usr/share/doc/${PN}-${PV}/pietray.py

  cd "${ED}/" || die "install dir: not found... error"

  find "$(get_libdir)/" -type f -name "*.la" -delete || die

  # simple test
  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'stest' && { bin/${PN} -v || : die "binary work... error";}

  ldd "bin/${PN}" || { use 'static' && true || : die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
