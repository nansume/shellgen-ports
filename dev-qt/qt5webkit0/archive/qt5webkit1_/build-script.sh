#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-29 19:00 UTC - last change
# Date: 2024-10-13 15:00 UTC - last change
# Build with useflag: -static-libs +shared +ssl -glib -lfs +nopie +patch -doc -xstub +musl +stest +strip +x32

# https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-qt/qtwebkit/qtwebkit-5.9.1.ebuild?id=${HASH}
# https://gitweb.gentoo.org/proj/musl.git/plain/dev-qt/qtwebkit/qtwebkit-5.9.1.ebuild?id=${HASH}

export XPN PF PV WORKDIR BUILD_DIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="WebKit rendering library for the Qt5 framework (deprecated)"
HOMEPAGE="https://www.qt.io"
LICENSE="custom / GPLv3 / LGPL / FDL"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
SPN="qtwebkit-opensource-src"
PV="5.9.1"
HASH="56a6822d7da1a3623c6d0cc0ee05ddd6f81de958"  # for qt5webkit-5.9.1 ebuild link
HASH="75406c8ad02e72b94234c6ec1b1317f944863c14"  # for musl overlay
HASH3="69e618c88a9134f754264efc11aa0b1fdc028b88"  # for fix-bison patch
SRC_URI="https://gitweb.gentoo.org/proj/musl.git/plain/dev-qt/qtwebkit"
GENTOO_WEBGIT="https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-qt/qtwebkit"
SRC_URI="
  https://download.qt.io/new_archive/qt/${PV%.*}/${PV}/submodules/qtwebkit-opensource-src-${PV}.tar.xz  # 5.9.1
  #https://download.qt.io/community_releases/${PV%.*}/${PV}-final/qtwebkit-opensource-src-${PV}.tar.xz  # 5.9.0
  ${SRC_URI}/files/qtwebkit-5.4.2-system-leveldb.patch?id=${HASH}
  ${SRC_URI}/files/qtwebkit-5.5.0-fix-backtrace-detection-musl.patch?id=${HASH}
  ${SRC_URI}/files/qtwebkit-5.5.1-fix-stack-size-musl.patch?id=${HASH}
  http://shellgen.mooo.com/pub/distfiles/qtwebkit-5.8.0-disable-gstreamer.patch
  http://shellgen.mooo.com/pub/distfiles/qtwebkit-5.5.1-disable-jit.patch
  http://shellgen.mooo.com/pub/distfiles/qtwebkit-5.6.2-icu-59.patch
  ${GENTOO_WEBGIT}/files/qtwebkit-5.212.0_pre20200309-bison-3.7.patch?id=${HASH3}
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-geolocation -gstreamer -gstreamer010 -jit -multimedia -opengl"
IUSE="${IUSE} -orientation -printsupport +qml -webchannel +webp -nopie"
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
ZCOMP="unxz"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${SPN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}

# Required minimal 6GB free space!

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
  "dev-db/bdb6  # deps ruby (optional)" \
  "dev-db/sqlite3  # required" \
  "dev-lang/ruby24  # support: ?ruby24 ?ruby25 ?ruby26" \
  "dev-lang/perl  # optional" \
  "dev-lang/python2  # for glib new version (python3 no-support)" \
  "dev-libs/expat  # icu,freetype" \
  "#dev-libs/glib-compat" \
  "dev-libs/glib74" \
  "dev-libs/gmp  # deps ruby" \
  "#dev-libs/leveldb  # no bundled" \
  "dev-libs/libexecinfo  # it needed backtrace?" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libyaml  # deps ruby (optional)" \
  "dev-libs/icu76  # deps qt5base" \
  "dev-libs/libxml2-1" \
  "dev-libs/libxslt" \
  "dev-libs/pcre2  # for glib74" \
  "dev-libs/openssl3  # deps ruby2* (optional)" \
  "dev-ruby/rubygems24  # deps ruby2* (optional)" \
  "dev-perl/digest-perl-md5" \
  "dev-qt/qt5base15" \
  "dev-qt/qt5declarative15" \
  "dev-util/gperf" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib" \
  "media-libs/freetype  # fontconfig" \
  "media-libs/fontconfig" \
  "media-libs/giflib" \
  "media-libs/gstreamer1" \
  "media-libs/gst-plugins-base1" \
  "media-libs/libjpeg-turbo3" \
  "media-libs/libpng" \
  "media-libs/libwebp1" \
  "media-libs/mesa  # for opengl (required)" \
  "net-print/cups" \
  "sys-apps/dbus" \
  "#sys-apps/file" \
  "sys-devel/binutils" \
  "#sys-devel/bison  # use bison-3.6 otherwise: error: CSSGrammar.hpp: No such file" \
  "sys-devel/bison2  # bison-3.6.4" \
  "sys-devel/flex" \
  "sys-devel/gcc14" \
  "sys-devel/m4  # required for flex" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset. (qtwebkit5.9.1)" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/gdbm0  # deps ruby (optional)" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  "#x11-base/xcb-proto" \
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
  "#x11-libs/xtrans" \
  "#x11-misc/xkeyboard-config" \
  "#x11-misc/util-macros" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

qt_use_disable_config() {
  FUNCNAME="${0##*/}"
  test "$#" -ge '3' || printf %s\\n "die: ${FUNCNAME}() requires at least three arguments"

  local flag=${1}  # no-posix
  local config=${2}  # no-posix
  shift 2

  if ! use "${flag}"; then
    echo "$@" | xargs sed -i -e "s/qtConfig(${config})/false/g" || printf %s\\n "die: ${FUNCNAME}()"
  fi
}

qt_use_disable_mod() {
  FUNCNAME="${0##*/}"
  test "$#" -ge '3' || printf %s\\n "die: ${FUNCNAME}() requires at least three arguments"

  local flag=${1}  # no-posix
  local module=${2}  # no-posix
  shift 2

  if ! use "${flag}"; then
    echo "$@" | xargs sed -i -e "s/qtHaveModule(${module})/false/g" || printf %s\\n "die: ${FUNCNAME}()"
  fi
}

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
  append-flags -Os -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc" CXX="c++"
  PATH="${PATH:+${PATH}:}/$(get_libdir)/qt5/bin"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  #gpatch -p1 -E < "${FILESDIR}/qtwebkit-5.4.2-system-leveldb.patch"
  gpatch -p1 -E < "${FILESDIR}/qtwebkit-5.5.0-fix-backtrace-detection-musl.patch"
  gpatch -p1 -E < "${FILESDIR}/qtwebkit-5.5.1-fix-stack-size-musl.patch"
  gpatch -p1 -E < "${FILESDIR}/qtwebkit-5.8.0-disable-gstreamer.patch"
  gpatch -p1 -E < "${FILESDIR}/qtwebkit-5.5.1-disable-jit.patch"
  #gpatch -p1 -E < "${FILESDIR}/qtwebkit-5.6.2-icu-59.patch" # bug 618644
  #gpatch -p1 -E < "${FILESDIR}/qtwebkit-5.212.0_pre20200309-bison-3.7.patch"  # or use bison-3.6

  # to avoid literally thousands of unneeded warning messages
  sed -e '/CONFIG/a QMAKE_CXXFLAGS += -Wno-expansion-to-defined' \
    -i Tools/qmake/mkspecs/features/unix/default_pre.prf || die
  # bug 466216
  sed -e '/CONFIG +=/s/rpath//' \
    -i Source/WebKit/qt/declarative/experimental/experimental.pri \
    -i Source/WebKit/qt/declarative/public.pri \
    -i Tools/qmake/mkspecs/features/force_static_libs_as_shared.prf \
    -i Tools/qmake/mkspecs/features/unix/default_post.prf \
    || die

  # disable opengl
  #sed -e '/: WEBKIT_CONFIG += use_3d_graphics/d' -i Tools/qmake/mkspecs/features/features.prf || die
  qt_use_disable_config opengl opengl Tools/qmake/mkspecs/features/features.prf

  qt_use_disable_mod geolocation positioning Tools/qmake/mkspecs/features/features.prf
  qt_use_disable_mod multimedia multimediawidgets Tools/qmake/mkspecs/features/features.prf
  qt_use_disable_mod orientation sensors Tools/qmake/mkspecs/features/features.prf
  qt_use_disable_mod printsupport printsupport Tools/qmake/mkspecs/features/features.prf
  qt_use_disable_mod qml quick Tools/qmake/mkspecs/features/features.prf
  qt_use_disable_mod webchannel webchannel \
   Source/WebKit2/Target.pri \
   Source/WebKit2/WebKit2.pri

  # bug 458222
  sed -e '/SUBDIRS += examples/d' -i Source/QtWebKit.pro || die

  mkdir -m 0755 -- ".git/"

  mkdir -pm 0755 -- "${BUILD_DIR}/build/"
  cd "${BUILD_DIR}/build/" || die "builddir: not found... error"

  qmake-qt5 ../WebKit.pro
  make -j "$(nproc --ignore=1)" || die "Failed make build"

  . runverb \
  make INSTALL_ROOT="${ED}" install || printf %s\\n 'die "make install... error"'

  cd "${ED}/" || die "install dir: not found... error"

  sed -e 's|${prefix}|/|g' -i "$(get_libdir)/"pkgconfig/Qt5*.pc
  sed -e '/^QMAKE_PRL_BUILD_DIR/d' -i "$(get_libdir)/"libQt5*.prl

  find "$(get_libdir)/" -name '*.la' -delete || : die

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
