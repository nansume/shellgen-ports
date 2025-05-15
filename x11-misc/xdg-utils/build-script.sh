#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-29 14:00 UTC - last change
# Build with useflag: -static -static-libs -shared +patch -doc -xstub -diet -musl -stest +noarch

# http://data.gpo.zugaina.org/gentoo/x11-misc/xdg-utils/xdg-utils-1.2.1-r4.ebuild
# https://www.linuxfromscratch.org/blfs/view/7.4/xsoft/xdg-utils.html

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
#export PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Portland utils for cross-platform/cross-toolkit/cross-desktop interoperability"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/xdg-utils/"
LICENSE="MIT"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="1.2.1"  # no build without xmlto
PV="1.0.2_p20101101"  # missing
PV="1.0.2"
SRC_URI="
  https://gitlab.freedesktop.org/xdg/xdg-utils/-/archive/v${PV}/${PN}-v${PV}.tar.bz2
  #https://portland.freedesktop.org/download/xdg-utils-1.1.3.tar.gz
  #http://data.gpo.zugaina.org/gentoo/x11-misc/xdg-utils/files/xdg-utils-1.2.1-xdg-mime-default.patch
  #http://data.gpo.zugaina.org/gentoo/x11-misc/xdg-utils/files/xdg-utils-1.2.1-qtpaths.patch
  #xdg-utils-1.0.2-arb-comm-exec.patch  # xdg-utils-1.0.2 - missing
  #xdg-utils-1.0.2-kdedirs.patch  # xdg-utils-1.0.2 - missing
  #xdg-utils-1.0.2-xdgopen-kde.patch  # xdg-utils-1.0.2 - missing
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
IUSE="-dbus -doc -gnome -plasma +X +static +static-libs +shared -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-v${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
#PKG_CONFIG="pkgconf"
#PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
#PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
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
  "#app-text/xmlto" \
  "dev-lang/perl  # required for autotools,file-mimeinfo" \
  "#dev-libs/glib-compat  # no required ?" \
  "#dev-libs/libffi  # no required ?" \
  "#dev-libs/libxml2" \
  "#dev-libs/libxslt" \
  "#dev-perl/encode-locale  # no required ?" \
  "#dev-perl/file-basedir  # no required ?" \
  "#dev-perl/file-desktopentry  # no required ?" \
  "dev-perl/file-mimeinfo" \
  "#dev-perl/ipc-system-simple  # no required ?" \
  "#dev-perl/regexp-ipv6  # no required ?" \
  "#dev-perl/uri  # no required ?" \
  "#dev-perl/net-dbus  # gnome?" \
  "#dev-perl/x11-protocol  # gnome?" \
  "#dev-qt/qt5base  # plasma? (qtpaths)" \
  "#dev-util/byacc  # alternative a bison" \
  "dev-util/desktop-file-utils" \
  "#dev-util/pkgconf  # plasma?" \
  "#kde-frameworks/kservice5  # plasma?" \
  "#sys-apps/dbus  # dbus?" \
  "sys-apps/gawk  # busybox awk no-compat?" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps desktop-file-utils" \
  "#x11-apps/xprop  # X?" \
  "#x11-apps/xset  # X?" \
  "#x11-base/xorg-proto  # no required ?" \
  "#x11-libs/libx11  # no required ?" \
  "#x11-libs/libxau  # no required ?" \
  "#x11-libs/libxcb  # no required ?" \
  "#x11-libs/libxdmcp  # no required ?" \
  "#x11-libs/libxext  # no required ?" \
  "#x11-libs/libxmu  # no required ?" \
  "#x11-misc/shared-mime-info" \
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

  : inherit autotools install-functions

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  #patch -p1 -E < "${FILESDIR}"/${P}-xdg-mime-default.patch
  #patch -p1 -E < "${FILESDIR}"/${PN}-1.2.1-qtpaths.patch

  #export ac_cv_path_XMLTO=": /bin/xmlto --skip-validation" #502166

  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    || die "configure... error"

  : make -C "scripts" scripts-clean
  make || die "Failed make build"

  make DESTDIR="${ED}" install || : die "make install... error"

  use 'doc' && dodoc RELEASE_NOTES
  use 'doc' && newdoc scripts/xsl/README README.xsl
  use 'doc' && dodoc -r scripts/html

  # Install default XDG_DATA_DIRS, bug #264647
  : echo XDG_DATA_DIRS=\"${EPREFIX}/usr/local/share\" > 30xdg-data-local || die
  : echo 'COLON_SEPARATED="XDG_DATA_DIRS XDG_CONFIG_DIRS"' >> 30xdg-data-local || die
  : doenvd 30xdg-data-local

  : echo XDG_DATA_DIRS=\"${EPREFIX}/usr/share\" > 90xdg-data-base || die
  : echo XDG_CONFIG_DIRS=\"${EPREFIX}/etc/xdg\" >> 90xdg-data-base || die
  : doenvd 90xdg-data-base

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN="all" pkg-create-cgz
