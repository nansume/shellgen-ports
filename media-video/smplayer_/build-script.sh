#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-27 20:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="Great Qt GUI front-end for mplayer/mpv"
HOMEPAGE="https://www.smplayer.info/"
LICENSE="GPL-2+ BSD-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="19.5.0"
PV="23.6.0"
SRC_URI="
  https://github.com/smplayer-dev/${PN}/releases/download/v${PV}/${PN}-${PV}.tar.bz2
  http://data.gpo.zugaina.org/gentoo/media-video/smplayer/files/smplayer-17.1.0-advertisement_crap.patch
  http://data.gpo.zugaina.org/gentoo/media-video/smplayer/files/smplayer-18.2.0-jobserver.patch
  http://data.gpo.zugaina.org/gentoo/media-video/smplayer/files/smplayer-18.3.0-disable-werror.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-bidi -debug -static -static-libs +shared -doc (+musl) +stest +strip"
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
  "dev-lang/perl  # optional" \
  "dev-lang/python38  for glib new version" \
  "dev-libs/expat  # icu,freetype" \
  "dev-libs/glib57" \
  "#dev-libs/glib74" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/icu59  # deps qt5base" \
  "dev-libs/libxml2" \
  "dev-libs/libxslt" \
  "#dev-perl/digest-perl-md5" \
  "dev-qt/qt5base" \
  "dev-qt/qt5declarative" \
  "dev-qt/qt5tools" \
  "media-libs/alsa-lib" \
  "media-libs/freetype  # fontconfig" \
  "media-libs/fontconfig" \
  "media-libs/mesa  # for opengl" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/bison" \
  "sys-devel/flex" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  "x11-base/xorg-proto" \
  "x11-libs/libdrm  # for opengl" \
  "x11-libs/libice" \
  "x11-libs/libpciaccess  # for opengl" \
  "x11-libs/libsm" \
  "x11-libs/libvdpau  # for opengl" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxcursor" \
  "x11-libs/libxdamage  # for opengl" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxfixes" \
  "x11-libs/libxft" \
  "x11-libs/libxi" \
  "x11-libs/libxinerama  # optional" \
  "x11-libs/libxrandr" \
  "x11-libs/libxrender" \
  "x11-libs/libxv  # optional" \
  "x11-libs/libxshmfence" \
  "x11-libs/libxxf86vm" \
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

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc$(usex static ' --static')"
  CXX="c++$(usex static ' --static')"
  PATH="${PATH:+${PATH}:}/$(get_libdir)/qt5/bin"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  gpatch -p1 -E < "${FILESDIR}/${PN}-17.1.0-advertisement_crap.patch"
   patch -p1 -E < "${FILESDIR}/${PN}-18.2.0-jobserver.patch"
  gpatch -p1 -E < "${FILESDIR}/${PN}-18.3.0-disable-werror.patch"

  # Upstream Makefile sucks
  sed \
    -e "/^PREFIX=/ s:/usr/local:${EPREFIX%/}:" \
    -e "/^DOC_PATH=/ s:packages/smplayer:${PF}:" \
    -i Makefile || die

  # Turn off online update checker, bug #479902
  sed \
    -e 's:DEFINES += UPDATE_CHECKER:#&:' \
    -e 's:DEFINES += CHECK_UPGRADED:#&:' \
    -i src/smplayer.pro || die

  # Turn off intrusive share widget
  sed -e 's:DEFINES += SHARE_WIDGET:#&:' -i src/smplayer.pro || die

  # Turn debug message flooding off
  if ! use 'debug'; then
    sed -e 's:#\(DEFINES += NO_DEBUG_ON_CONSOLE\):\1:' -i src/smplayer.pro || die
  fi

  # Do not default compress man page
  sed '/gzip -9.*\.1$/d' -i Makefile || die
  sed 's@\.gz$@@' -i smplayer.spec || die

  cd "src/" || die
  qmake-qt5 QT_MAJOR_VERSION="5"

  cd "${BUILD_DIR}/"
  make -j "$(nproc)" CC="${CC}" || die "Failed make build"

  cd "${BUILD_DIR}/src/translations/" || die

  for LNG in en_US et ja ru_RU; do
    "/$(get_libdir)/qt5/bin"/lrelease ${PN}_${LNG}.ts
  done

  cd "${BUILD_DIR}/"
  make DESTDIR="${ED}" install || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  strip --verbose --strip-all "bin/"*

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
