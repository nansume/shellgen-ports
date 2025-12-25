#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-12-21 17:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-voip/mumble/mumble-1.5.735-r2.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="Mumble is an open source, low-latency, high quality voice chat software"
HOMEPAGE="https://wiki.mumble.info"
LICENSE="BSD MIT"
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="1.5.735"
#PV="1.5.634"
SRC_URI="
  https://github.com/mumble-voip/mumble/releases/download/v${PV}/${PN}-${PV}.tar.gz
  http://localhost/pub/distfiles/mumble-1.5.634-musl-1.2.3.patch
  http://localhost/pub/distfiles/mumble-1.5.634-EVIO-int.patch
  http://localhost/pub/distfiles/mumble-1.5.634-32-bit.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
inst="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+alsa -debug -g15 -jack -pipewire -portaudio -pulseaudio -multilib -nls -rnnoise -speech -test -zeroconf"
IUSE="${IUSE} -static +shared +doc (+musl) +stest +strip"
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
CMAKE_PREFIX_PATH="/${LIB_DIR}/cmake"
PROG=${PN}

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
  "#app-accessibility/speech-dispatcher  # speech" \
  "app-crypt/libb2  # deps python (optional)" \
  "app-misc/g15daemon  # g15" \
  "dev-build/cmake3  # cmake4" \
  "#dev-build/samurai  # alternative for ninja" \
  "dev-cpp/abseil-cpp1" \
  "dev-cpp/ms-gsl" \
  "dev-cpp/nlohmann-json" \
  "dev-db/sqlite3  # deps qt5" \
  "dev-lang/python3-12  # build deps" \
  "dev-libs/cxx-boost" \
  "dev-libs/expat  # deps qt5" \
  "dev-libs/glib74  # deps qt5" \
  "dev-libs/gmp  # deps qt5" \
  "dev-libs/icu76  # deps qt5" \
  "dev-libs/libffi  # bdeps python" \
  "dev-libs/libxml2-1  # deps qt5" \
  "dev-libs/libxslt  # deps qt5" \
  "dev-libs/pcre2  # deps qt5" \
  "dev-libs/poco  # poco[util,xml,zip]" \
  "dev-libs/protobuf" \
  "dev-libs/openssl3" \
  "dev-libs/libutf8proc" \
  "dev-qt/qt5base15  # qt5dbus,qt5core,qt5concurrent,qt5gui,qt5network[ssl],qt5test" \
  "dev-qt/qt5sql15  # qt5sql[sqlite]" \
  "dev-qt/qt5svg15" \
  "dev-qt/qt5widgets15" \
  "dev-qt/qt5xml15" \
  "dev-qt/qt5tools15  # linguist-tools5" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib  # alsa" \
  "media-libs/flac  # deps libsndfile" \
  "media-libs/freetype  # deps qt5" \
  "media-libs/fontconfig  # deps qt5" \
  "media-libs/giflib  # deps qt5" \
  "media-libs/gstreamer1  # deps qt5" \
  "media-libs/gst-plugins-base1  # deps qt5" \
  "media-libs/harfbuzz2-2  # deps qt5" \
  "media-libs/libjpeg-turbo3  # deps qt5" \
  "media-libs/libpng  # deps qt5" \
  "media-libs/libogg  # deps libsndfile" \
  "#media-libs/libpulse  # pulseaudio" \
  "media-libs/libsndfile  # libsndfile[-minimal]" \
  "media-libs/libvorbis # deps libsndfile" \
  "media-libs/mesa  # deps qt5" \
  "#media-libs/portaudio  # portaudio" \
  "#media-libs/rnnoise  # rnnoise" \
  "media-libs/opus" \
  "media-libs/speex" \
  "media-libs/speexdsp" \
  "media-sound/lame  # deps libsndfile" \
  "media-sound/mpg123  # deps libsndfile" \
  "#media-video/pipewire  # pipewire" \
  "#net-dns/avahi  # zeroconf, avahi[mdnsresponder-compat]" \
  "net-print/cups  # deps qt5" \
  "sys-apps/dbus  # deps qt5" \
  "#sys-apps/lsb-release" \
  "sys-devel/binutils9  # binutils6" \
  "sys-devel/gcc14  # gcc6" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps qt5" \
  "x11-base/xcb-proto" \
  "x11-base/xorg-proto" \
  "x11-libs/libdrm  # for opengl" \
  "x11-libs/libice" \
  "x11-libs/libpciaccess  # for opengl" \
  "x11-libs/libvdpau  # for opengl" \
  "x11-libs/libsm" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxcursor" \
  "x11-libs/libxdamage  # for ?opengl" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxfixes" \
  "x11-libs/libxft" \
  "x11-libs/libxi" \
  "x11-libs/libxinerama  # optional" \
  "x11-libs/libxkbcommon  # for built with x11 support" \
  "x11-libs/libxrandr" \
  "x11-libs/libxrender" \
  "x11-libs/libxshmfence  # for ?opengl" \
  "x11-libs/libxv  # optional" \
  "x11-libs/libxt  # dbus" \
  "x11-libs/libxxf86vm  # for ?opengl" \
  "x11-libs/xcb-util  # ?for xcb" \
  "x11-libs/xcb-util-cursor" \
  "x11-libs/xcb-util-image  # ?for xcb" \
  "x11-libs/xcb-util-keysyms  # ?for xcb" \
  "x11-libs/xcb-util-renderutil  # ?for xcb" \
  "x11-libs/xcb-util-wm  # ?for xcb" \
  "x11-libs/xtrans" \
  "x11-misc/util-macros" \
  "x11-misc/xkeyboard-config" \
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
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  # https://bugs.gentoo.org/832978
  # fix tests (and possibly runtime issues) on arches with unsigned chars
  append-cxxflags -fsigned-char

  CC="gcc" CXX="g++"

  use 'strip' && inst="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  #patch -p1 -E < "${FILESDIR}"/${PN}-1.5.735-Fix-building-with-GCC-15.patch
  #patch -p1 -E < "${FILESDIR}"/mumble-1.5.634-musl-1.2.3.patch
  patch -p1 -E < "${FILESDIR}"/mumble-1.5.634-EVIO-int.patch
  #patch -p1 -E < "${FILESDIR}"/mumble-1.5.634-32-bit.patch

  sed '/TRACY_ON_DEMAND/s@ ON @ OFF @' -i src/CMakeLists.txt || die

  #cmake -B build -G Ninja \
  cmake -B build -G "Unix Makefiles" \
    -D CMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -D CMAKE_INSTALL_BINDIR="bin" \
    -D CMAKE_INSTALL_LIBDIR="$(get_libdir)" \
    -D CMAKE_INSTALL_INCLUDEDIR="${INCDIR#/}" \
    -D CMAKE_INSTALL_DATAROOTDIR="${DPREFIX#/}/share" \
    -D CMAKE_INSTALL_DOCDIR="${DPREFIX#/}/share/doc" \
    -D CMAKE_BUILD_TYPE="Release" \
    -D alsa=$(usex 'alsa' ON OFF) \
    -D bundled-gsl="OFF" \
    -D bundled-json="OFF" \
    -D bundled-speex="OFF" \
    -D bundled-opus="OFF" \
    -D bundled-rnnoise="OFF" \
    -D bundle-qt-translations="OFF" \
    -D g15=$(usex 'g15' ON OFF) \
    -D jackaudio="OFF" \
    -D overlay="OFF" \
    -D portaudio=$(usex 'portaudio' ON OFF) \
    -D overlay-xcompile="OFF" \
    -D pipewire=$(usex 'pipewire' ON OFF) \
    -D pulseaudio=$(usex 'pulseaudio' ON OFF) \
    -D renamenoise=$(usex 'rnnoise' ON OFF) \
    -D rnnoise=$(usex 'rnnoise' ON OFF) \
    -D ice="OFF" \
    -D server="OFF" \
    -D speechd="OFF" \
    -D tests=$(usex 'test' ON OFF) \
    -D tracy="OFF" \
    -D xinput2="OFF" \
    -D translations=$(usex 'nls' ON OFF) \
    -D plugins="OFF" \
    -D manual-plugin="OFF" \
    -D update="OFF" \
    -D warnings-as-errors="OFF" \
    -D zeroconf=$(usex 'zeroconf' ON OFF) \
    -D crash-report="OFF" \
    -D static="OFF" \
    -D BUILD_NUMBER="${PV##*.}" \
    -D BUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  #ninja -j "$(nproc)" -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${ED}" cmake --build build --target ${inst} -j "$(nproc)" || die "make install... error"
  #DESTDIR="${ED}" cmake --install build $(usex 'strip' --strip) || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -vr -- "usr/share/man/" "usr/share/"

  use 'stest' && { bin/${PROG} --version || : die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || : die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz