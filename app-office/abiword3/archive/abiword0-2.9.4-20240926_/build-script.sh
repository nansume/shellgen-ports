#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-26 17:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# 
# ie_exp_XSL-FO.cpp: error: unable to find string literal operator 'operator""x' with 'const char [4]', 'unsigned
# int' arguments

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Fully featured yet light and fast cross platform word processor"
HOMEPAGE="http://www.abisource.com/"
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
PN=${PN%[0-9]*}
PV="2.9.4"
SRC_URI="
  http://ftp2.osuosl.org/pub/blfs/conglomeration/abiword/abiword-${PV}.tar.gz
  https://dev.gentoo.org/~soap/distfiles/${PN}-3.0.4-patchset-r3.txz -> ${PN}-3.0.4-patchset-r3.tar.xz
  http://data.gpo.zugaina.org/gentoo/app-office/abiword/files/abiword-3.0.5-musl-lose-precision-fix.patch
  http://data.gpo.zugaina.org/gentoo/app-office/abiword/files/abiword-3.0.5-libxml2-2.12.patch
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
IUSE="-doc (+musl) +stest +strip"
IUSE="${IUSE} -calendar -collab +cups -debug -eds +goffice -grammar -introspection -latex -map"
IUSE="${IUSE} -math -ots +plugins -readline -redland -spell -wordperfect -wmf -thesaurus"
IUSE="${IUSE} -cups -goffice +plugins"
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
  "app-accessibility/at-spi2-core" \
  "app-accessibility/at-spi2-atk  # required" \
  "app-text/wv" \
  "dev-lang/perl  # required for autotools" \
  "dev-lang/python3" \
  "dev-libs/atk" \
  "dev-libs/cxx-boost" \
  "dev-libs/expat  # for fontconfig or python bundled" \
  "dev-libs/fribidi  # for pango (required remove)" \
  "dev-libs/glib" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libgcrypt  # deps libgpg-error" \
  "dev-libs/libgpg-error" \
  "dev-libs/libxml2  # for gettext" \
  "dev-libs/libxslt  # required" \
  "dev-libs/pcre  # optional (internal pcre glib-2.68.4)" \
  "dev-libs/libcroco  # deps librsvg" \
  "dev-util/byacc" \
  "dev-util/pkgconf" \
  "gnome-extra/libgsf" \
  "gnome-base/librsvg" \
  "media-libs/libepoxy  # required" \
  "media-libs/freetype" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz2  # for pango" \
  "media-libs/libjpeg-turbo  # for gdk-pixbuf or bundled-libs" \
  "media-libs/libpng  # for pango or bundled-libs" \
  "media-libs/mesa  # deps libepoxy" \
  "media-libs/tiff  # for gdk-pixbuf" \
  "sys-apps/dbus  # deps at-spi2-atk" \
  "sys-apps/file" \
  "sys-devel/autoconf  # required for autotools" \
  "sys-devel/automake  # required for autotools" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/gettext  # required for autotools (optional)" \
  "sys-devel/lex" \
  "sys-devel/libtool  # required for autotools" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl  # testing" \
  "sys-libs/musl" \
  "sys-libs/zlib  # for glib or bundled-libs" \
  "x11-base/xorg-proto  # deps for gtk" \
  "x11-libs/cairo  # deps for gtk" \
  "x11-libs/goffice10" \
  "x11-libs/libdrm  # for mesa" \
  "x11-libs/libpciaccess  # for mesa" \
  "x11-libs/libvdpau  # for mesa" \
  "x11-libs/libice  # deps for gtk" \
  "x11-libs/libsm  # deps for gtk" \
  "x11-libs/libx11  # deps for gtk" \
  "x11-libs/libxau  # deps for gtk" \
  "x11-libs/libxcb  # deps for gtk" \
  "x11-libs/libxcomposite  # deps for gtk" \
  "x11-libs/libxcursor  # deps for gtk" \
  "x11-libs/libxdamage  # required" \
  "x11-libs/libxdmcp  # deps for gtk" \
  "x11-libs/libxext  # deps for gtk" \
  "x11-libs/libxfixes  # deps for gtk" \
  "x11-libs/libxft  # deps for gtk" \
  "x11-libs/libxi  # required" \
  "x11-libs/libxrandr  # required" \
  "x11-libs/libxrender  # deps for gtk" \
  "x11-libs/libxshmfence  # for mesa" \
  "x11-libs/libxxf86vm  # for mesa" \
  "x11-libs/libxt  # deps at-spi2-atk" \
  "x11-libs/pango  # deps for gtk" \
  "x11-libs/pixman  # deps for gtk" \
  "x11-libs/gdk-pixbuf  # deps for gtk2" \
  "x11-libs/gtk2" \
  "x11-libs/gtk3" \
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

  for PF in *.tar.xz ${PF}; do
    case ${PF} in *.gz) ZCOMP="gunzip";; *.xz) ZCOMP="unxz";; esac
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-cxxflags -std=c++03
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc" CXX="c++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${WORKDIR}"/patches/${PN}-2.6.0-boolean.patch
  patch -p1 -E < "${WORKDIR}"/patches/${PN}-2.8.3-desktop.patch
  #patch -p1 -E < "${WORKDIR}"/patches/${PN}-3.0.4-asio-standalone-placeholders.patch
  #patch -p1 -E < "${WORKDIR}"/patches/${PN}-3.0.4-c++17-dynamic-exception-specifications.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-3.0.5-musl-lose-precision-fix.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-3.0.5-libxml2-2.12.patch

  PLUGINS=
  if use 'plugins'; then
    # Plugins depending on libgsf
    PLUGINS="t602 docbook clarisworks wml kword hancom openwriter pdf loadbindings"
    PLUGINS="${PLUGINS} mswrite garble pdb applix opendocument sdw xslfo"
    # Plugins depending on librsvg
    PLUGINS="${PLUGINS} svg"
    # Plugins not depending on anything
    PLUGINS="${PLUGINS} gimp bmp freetranslation iscii s5 babelfish opml eml wikipedia"
    PLUGINS="${PLUGINS} gdict passepartout google presentation urldict hrtext mif openxml"
    use 'collab' && PLUGINS="${PLUGINS} collab"
    use 'goffice' && PLUGINS="${PLUGINS} goffice"
    use 'latex' && PLUGINS="${PLUGINS} latex"
    use 'math' && PLUGINS="${PLUGINS} mathview"
    use 'ots' && PLUGINS="${PLUGINS} ots"
    # psion: >=psiconv-0.9.4
    use 'readline' && PLUGINS="${PLUGINS} command"
    use 'thesaurus' && PLUGINS="${PLUGINS} aiksaurus"
    use 'wmf' && PLUGINS="${PLUGINS} wmf"
    # wordperfect: >=wpd-0.9 >=wpg-0.2
    use 'wordperfect' && PLUGINS="${PLUGINS} wpg"
  fi

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
    --host=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
    --build=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
    --disable-maintainer-mode \
    --enable-plugins="${PLUGINS}" \
    --disable-default-plugins \
    --disable-builtin-plugins \
    --disable-collab-backend-telepathy \
    --enable-clipart \
    --enable-statusbar \
    --enable-templates \
    --with-gio \
    --without-gnomevfs \
    --disable-debug \
    $(use_with 'goffice' goffice) \
    $(use_with 'calendar' libical) \
    $(use_enable 'cups' print) \
    $(use_enable 'collab' collab-backend-xmpp) \
    $(use_enable 'collab' collab-backend-tcp) \
    $(use_enable 'collab' collab-backend-service) \
    $(use_with 'eds' evolution-data-server) \
    --disable-introspection \
    $(use_with 'map' champlain) \
    $(use_with 'redland') \
    $(use_enable 'spell') \
    $(use_enable 'shared') \
    --disable-static \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  find "$(get_libdir)/" -name '*.la' -delete || die

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)/${PN}"

  use 'stest' && { bin/${PN} --version || : die "binary work... error";}
  ldd "bin/${PN}" || : die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
