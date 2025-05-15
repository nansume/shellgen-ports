#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-10-14 19:00 UTC - last change
# Build with useflag: -static-libs +shared +ssl -glib -lfs +nopie +patch -doc -xstub +musl +stest +strip +x32

# https://data.gpo.zugaina.org/gentoo/www-client/otter/otter-1.0.03-r1.ebuild

export XPN PF PV WORKDIR BUILD_DIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="Project aiming to recreate classic Opera (12.x) UI using Qt5"
HOMEPAGE="https://otter-browser.org/"
LICENSE="GPL-3"
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
PROG="${PN}-browser"
PV="1.0.03"
PV="0.9.97"
SRC_URI="https://github.com/OtterBrowser/otter-browser/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-dbus -spell -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-browser-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
CMAKE_PREFIX_PATH="/${LIB_DIR}/cmake"

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
  "app-misc/ca-certificates" \
  "#app-text/hunspell  # for spellcheck (hunspell must have sharedlib)" \
  "dev-db/bdb6  # deps ruby (optional)" \
  "dev-db/sqlite  # required" \
  "dev-lang/ruby24  # support: ?ruby24 ?ruby25 ?ruby26" \
  "dev-lang/perl  # optional" \
  "dev-lang/python2  # for glib new version (python3 no-support)" \
  "dev-libs/expat  # icu,freetype" \
  "dev-libs/glib-compat" \
  "#dev-libs/glib" \
  "dev-libs/gmp  # deps ruby" \
  "#dev-libs/leveldb  # no bundled" \
  "dev-libs/libexecinfo  # it needed backtrace?" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libyaml  # deps ruby (optional)" \
  "dev-libs/icu-compat  # deps qt5base" \
  "#dev-libs/libxml2" \
  "#dev-libs/libxslt" \
  "dev-libs/openssl  # deps ruby2* (optional)" \
  "dev-ruby/rubygems24  # deps ruby2* (optional)" \
  "dev-perl/digest-perl-md5" \
  "dev-qt/qt5base" \
  "dev-qt/qt5declarative" \
  "dev-qt/qt5multimedia" \
  "dev-qt/qt5svg" \
  "dev-qt/qt5webkit" \
  "dev-qt/qt5xmlpatterns" \
  "dev-util/cmake" \
  "dev-util/gperf" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib" \
  "media-libs/freetype  # fontconfig" \
  "media-libs/fontconfig  # deps: qt5multimedia" \
  "media-libs/gstreamer1  # deps: qt5multimedia" \
  "#media-libs/gst-plugins-base1" \
  "#media-libs/libjpeg-turbo" \
  "#media-libs/libpng" \
  "media-libs/libwebp" \
  "media-libs/mesa  # for opengl (required)" \
  "sys-devel/binutils" \
  "sys-devel/bison  # use bison-3.6 otherwise: error: CSSGrammar.hpp: No such file" \
  "#sys-devel/bison2  # bison-3.6.4" \
  "sys-devel/flex" \
  "sys-devel/gcc9" \
  "sys-devel/m4  # required for flex" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset. (qtwebkit5.9.1)" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/gdbm0  # deps ruby (optional)" \
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

  : inherit python-any-r1 qt5-build install-functions
  . "${PDIR%/}/etools.d/"epython

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc" CXX="c++"
  PATH="${PATH:+${PATH}:}/$(get_libdir)/qt5/bin"

  use 'strip' && INSTALL_OPTS="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  mkdir -m 0755 -- "${BUILD_DIR}/build/"
  cd "${BUILD_DIR}/build/" || die "builddir: not found... error"

  . runverb \
  cmake \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}/usr" \
    -DCMAKE_INSTALL_BINDIR="bin" \
    -DCMAKE_INSTALL_DATAROOTDIR="share" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DENABLE_DBUS=$(usex 'dbus') \
    -DENABLE_QTWEBENGINE="OFF" \
    -DENABLE_QTWEBKIT="ON" \
    -DENABLE_SPELLCHECK=$(usex 'spell') \
    -DCMAKE_SKIP_RPATH="ON" \
    -DCMAKE_SKIP_INSTALL_RPATH="ON" \
    -Wno-dev \
    .. || die "Failed cmake build"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${BUILD_DIR}/"

  #mv -n ${PN}-browser.desktop -t ${ED}"/usr/share/applications/

  cd "${ED}/" || die "install dir: not found... error"

  mv -v -n "usr/bin" -t .

  for P in usr/share/otter-browser/locale/*.qm; do
    case ${P} in *'_en_US.'*|*'_et.'*|*'_ja.'*|*'_ru.'*) continue;; esac
    rm -v -- "${P}"
  done

  use 'stest' && { bin/${PROG} --version || : die "binary work... error";}
  ldd "bin/${PROG}" || die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
