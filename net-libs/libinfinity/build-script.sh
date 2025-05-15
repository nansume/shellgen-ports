#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-05-04 06:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# BUG: no-build with +server

# http://data.gpo.zugaina.org/stuff/net-libs/libinfinity/libinfinity-0.7.2.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="An implementation of the Infinote protocol written in GObject-based C"
HOMEPAGE="https://gobby.github.io/"
LICENSE="LGPL-2.1"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
#PN=${PN%[0-9]}
PV="0.7.2"
SLOT="0.7"
SRC_URI="https://github.com/gobby/${PN}/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"  # no-build
SRC_URI="http://releases.0x539.de/${PN}/${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-avahi -doc -gtk2 +gtk3 -server -static-libs +shared (+musl) +stest +strip"
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
  "app-accessibility/at-spi2-atk  # for atk" \
  "app-accessibility/at-spi2-core" \
  "app-text/libpaper  # required for cups (optional)" \
  "#dev-build/autoconf71  # required for autotools" \
  "#dev-build/automake16  # required for autotools" \
  "#dev-lang/perl  # required for autotools" \
  "dev-lang/python3-8" \
  "dev-libs/atk" \
  "dev-libs/expat  # for fontconfig or python bundled" \
  "dev-libs/fribidi  # for pango (required remove)" \
  "dev-libs/glib74" \
  "dev-libs/gmp  # deps ssl" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libgcrypt  # deps gsasl" \
  "dev-libs/libgpg-error  # deps gsasl" \
  "dev-libs/libxml2-1" \
  "dev-libs/libtasn1  # deps gnutls" \
  "dev-libs/libunistring  # deps gnutls" \
  "dev-libs/nettle  # deps gnutls" \
  "dev-libs/pcre2  # deps glib74" \
  "dev-util/pkgconf" \
  "media-libs/freetype" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz2-1  # for pango" \
  "media-libs/libepoxy" \
  "media-libs/libjpeg-turbo3  # for gdk-pixbuf or bundled-libs" \
  "media-libs/libpng  # for pango or bundled-libs" \
  "media-libs/mesa  # required for libepoxy (opengl)" \
  "media-libs/tiff  # for gdk-pixbuf" \
  "net-libs/gnutls" \
  "net-misc/gsasl" \
  "sys-apps/dbus  # for atk" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/gettext-tiny  # required for autotools (optional)" \
  "sys-devel/libtool  # required for autotools,libtoolize" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/pam" \
  "sys-libs/zlib  # deps glib, gnutls" \
  "x11-base/xorg-proto" \
  "x11-libs/cairo  # optional" \
  "x11-libs/gtk3" \
  "x11-libs/gdk-pixbuf" \
  "x11-libs/libdrm  # for mesa (optional)" \
  "x11-libs/libice" \
  "x11-libs/libpciaccess  # for mesa (optional)" \
  "x11-libs/libsm" \
  "x11-libs/libvdpau  # for mesa (optional)" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxcomposite" \
  "x11-libs/libxcursor" \
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

#if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
#  printf '#!/bin/sh' > /bin/gtkdocize
#  printf 'case ${@} in *--version*)echo "version 1.4";; esac' >> /bin/gtkdocize
#  chmod +x /bin/gtkdocize
#fi

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"  # only for user-build

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

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

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  #sed -e 's/want_gtk_doc=true/want_gtk_doc=false/' -i autogen.sh

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
    $(use_enable 'doc' gtk-doc) \
    --disable-introspection \
    --with-inftextgtk \
    --with-infgtk \
    $(use_with 'server' infinoted) \
    --without-gio \
    $(use_with 'avahi') \
    --without-libdaemon \
    --without-libsystemd \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || : die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  rm -r -- "$(get_libdir)/locale/"

  if use 'server'; then
    #newinitd "${FILESDIR}/infinoted.initd" infinoted
    #newconfd "${FILESDIR}/infinoted.confd" infinoted

    #keepdir /var/lib/infinote
    #fowners infinote:infinote /var/lib/infinote
    #fperms 770 /var/lib/infinote

    ln -s infinoted-${PV%.*} bin/infinoted
  fi

  ldd "$(get_libdir)"/${PN}-*.so || : die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz