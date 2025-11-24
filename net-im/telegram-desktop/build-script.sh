#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-05-30 22:00 UTC, 2025-06-28 19:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-im/telegram-desktop/telegram-desktop-5.14.3.ebuild
# aports-3.21.3/community/telegram-desktop/APKBUILD

# TIP: required >10GB free space
# TIP: rm -- build/tdesktop-*-full/build/Telegram/CMakeFiles/*.dir/cmake_pch.hxx.gch

# UPDATE: CMAKE_DISABLE_PRECOMPILE_HEADERS=OFF -> CMAKE_DISABLE_PRECOMPILE_HEADERS=ON
# UPDATE: add <DESKTOP_APP_DISABLE_CRASH_REPORTS=ON>
# UPDATE: add <#media-libs/pulseaudio  # ?required>
# UPDATE: CMAKE_BUILD_TYPE=Release -> CMAKE_BUILD_TYPE=MinSizeRel
# UPDATE: add patch <small-sizes.patch> from postmarketOS
# UPDATE: replace gcc flag: -Os // -Oz
# UPDATE: add fallback for TDESKTOP_API_ID, TDESKTOP_API_HASH

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="Official desktop client for Telegram"
HOMEPAGE="https://desktop.telegram.org https://github.com/telegramdesktop/tdesktop"
LICENSE="BSD GPL-3-with-openssl-exception LGPL-2+"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="5.14.3"
SPN="tdesktop-${PV}-full"
URI="data.gpo.zugaina.org/gentoo/net-im/telegram-desktop/files"
SRC_URI="
  https://github.com/telegramdesktop/tdesktop/releases/download/v${PV}/${SPN}.tar.gz
  http://${URI}/tdesktop-4.2.4-jemalloc-only-telegram-r1.patch
  http://${URI}/tdesktop-5.2.2-qt6-no-wayland.patch
  http://${URI}/tdesktop-5.2.2-libdispatch.patch
  http://${URI}/tdesktop-5.7.2-cstring.patch
  http://${URI}/tdesktop-5.8.3-cstdint.patch
  http://${URI}/tdesktop-5.12.3-fix-webview.patch
  http://${URI}/tdesktop-5.14.3-system-cppgir.patch
  http://localhost/aports-3.21.3/community/telegram-desktop/small-sizes.patch -> tdesktop-small-sizes.patch
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
IUSE="+dbus +enchant +fonts +jemalloc -libdispatch -screencast -wayland -webkit +X"
IUSE="${IUSE} -static +shared -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${SPN}"
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
  "app-arch/lz4" \
  "#app-misc/ca-certificates  # openssl" \
  "app-text/aspell  # deps enchant" \
  "app-text/enchant2-2  # enchant?" \
  "#app-text/hunspell  # !enchant?" \
  "dev-build/cmake4" \
  "dev-build/samurai  # alternative for ninja" \
  "dev-cpp/abseil-cpp1" \
  "dev-cpp/ada" \
  "dev-cpp/cppgir" \
  "dev-cpp/expected-lite" \
  "dev-cpp/glibmm74" \
  "dev-cpp/ms-gsl" \
  "dev-cpp/range-v3" \
  "dev-lang/perl  # optional" \
  "dev-lang/python3-8  # required, for python3-10 needed <pyexpat>" \
  "#dev-lang/ruby26  # past ruby26" \
  "dev-lang/vala  # deps gobject-introspection" \
  "dev-libs/cxx-boost" \
  "dev-libs/crc32c" \
  "dev-libs/expat  # icu,freetype" \
  "dev-libs/gobject-introspection74" \
  "dev-libs/glib74" \
  "dev-libs/gmp  # for ssl" \
  "dev-libs/icu76  # pre: icu64" \
  "dev-libs/jemalloc" \
  "#dev-libs/libdispatch  # it missing" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libfmt" \
  "dev-libs/libxml2-1" \
  "dev-libs/libxslt" \
  "dev-libs/pcre2  # for glib74" \
  "dev-libs/protobuf" \
  "dev-libs/openssl3" \
  "dev-libs/xxhash" \
  "#dev-perl/digest-perl-md5" \
  "#dev-perl/perl-file-spec  # no required, it part perl." \
  "#dev-perl/perl-getopt-long  # no required, it part perl." \
  "dev-qt/qt6base" \
  "dev-qt/qt6imageformats" \
  "dev-qt/qt6svg" \
  "#dev-util/byacc  # alternative a bison" \
  "dev-util/gperf" \
  "dev-util/pkgconf" \
  "#kde-frameworks/kcoreaddons6  # it missing" \
  "media-libs/alsa-lib" \
  "media-libs/freetype  # fontconfig" \
  "media-libs/fontconfig" \
  "media-libs/giflib" \
  "media-libs/gstreamer1" \
  "media-libs/gst-plugins-base1" \
  "media-libs/libjpeg-turbo3" \
  "media-libs/libtgvoip" \
  "media-libs/libv4l  # deps ffmpeg" \
  "media-libs/libvpx1  # deps ffmpeg" \
  "media-libs/mesa  # for opengl" \
  "#media-libs/pulseaudio  # ?required" \
  "media-libs/rnnoise" \
  "media-libs/openal" \
  "media-libs/openh264" \
  "media-libs/opus" \
  "media-libs/tg-owt" \
  "media-video/ffmpeg7" \
  "#net-libs/webkit-gtk6  # or webkit-gtk4, it missing" \
  "net-print/cups" \
  "net-libs/tdlib" \
  "sys-apps/dbus" \
  "sys-apps/file" \
  "sys-devel/binutils9" \
  "sys-devel/bison" \
  "sys-devel/flex" \
  "sys-devel/gcc14" \
  "#sys-devel/lex  # alternative a flex" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "#sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib  # for ssl" \
  "#x11-base/xcb-proto" \
  "x11-base/xorg-proto" \
  "x11-libs/libdrm  # for opengl" \
  "x11-libs/libice" \
  "x11-libs/libpciaccess  # for opengl" \
  "x11-libs/libvdpau  # for opengl" \
  "x11-libs/libsm" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxcomposite  # deps tg-owt" \
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
  "x11-libs/libxtst  # deps tg-owt" \
  "x11-libs/libxxf86vm  # for ?opengl" \
  "x11-libs/xcb-util  # ?for xcb" \
  "x11-libs/xcb-util-cursor" \
  "x11-libs/xcb-util-image  # ?for xcb" \
  "x11-libs/xcb-util-keysyms  # ?for xcb" \
  "x11-libs/xcb-util-renderutil  # ?for xcb" \
  "x11-libs/xcb-util-wm  # ?for xcb" \
  "x11-libs/xtrans" \
  "#x11-misc/util-macros" \
  "#x11-misc/xkeyboard-config" \
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
  append-flags -Oz -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  gpatch -p1 -E < "${FILESDIR}"/tdesktop-4.2.4-jemalloc-only-telegram-r1.patch
  gpatch -p1 -E < "${FILESDIR}"/tdesktop-5.2.2-qt6-no-wayland.patch
  gpatch -p1 -E < "${FILESDIR}"/tdesktop-5.2.2-libdispatch.patch
  gpatch -p1 -E < "${FILESDIR}"/tdesktop-5.7.2-cstring.patch
  patch -p1 -E < "${FILESDIR}"/tdesktop-5.8.3-cstdint.patch
  patch -p1 -E < "${FILESDIR}"/tdesktop-5.12.3-fix-webview.patch  # with patch same correct.
  patch -p1 -E < "${FILESDIR}"/tdesktop-5.14.3-system-cppgir.patch

  # Happily fail if libraries aren't found...
  find -type f \( -name 'CMakeLists.txt' -o -name '*.cmake' \) \
   \! -path './Telegram/lib_webview/CMakeLists.txt' \
   \! -path './cmake/external/expected/CMakeLists.txt' \
   \! -path './cmake/external/kcoreaddons/CMakeLists.txt' \
   \! -path './cmake/external/qt/package.cmake' \
   -print0 | xargs -0 sed -i \
   -e '/pkg_check_modules(/s/[^ ]*)/REQUIRED &/' \
   -e '/find_package(/s/)/ REQUIRED)/' || die
  # Make sure to check the excluded files for new
  # CMAKE_DISABLE_FIND_PACKAGE entries.

  # Some packages are found through pkg_check_modules, rather than find_package
  sed -e '/find_package(lz4 /d' -i cmake/external/lz4/CMakeLists.txt || die
  sed -e '/find_package(Opus /d' -i cmake/external/opus/CMakeLists.txt || die
  sed -e '/find_package(xxHash /d' -i cmake/external/xxhash/CMakeLists.txt || die

  # Control QtDBus dependency from here, to avoid messing with QtGui.
  # QtGui will use find_package to find QtDbus as well, which
  # conflicts with the -DCMAKE_DISABLE_FIND_PACKAGE method.
  if ! use 'dbus'; then
    sed -e '/find_package(Qt[^ ]* OPTIONAL_COMPONENTS/s/DBus *//' \
     -i cmake/external/qt/package.cmake || die
  fi

  # Control automagic dep only needed when USE="webkit wayland"
  if ! use webkit || ! use wayland; then
    sed -e 's/QT_CONFIG(wayland_compositor_quick)/0/' \
     -i Telegram/lib_webview/webview/platform/linux/webview_linux_compositor.h || die
  fi

  ##################################################################################

  # Having user paths sneak into the build environment through the
  # XDG_DATA_DIRS variable causes all sorts of weirdness with cppgir:
  # - bug 909038: can't read from flatpak directories (fixed upstream)
  # - bug 920819: system-wide directories ignored when variable is set
  export XDG_DATA_DIRS="${EPREFIX%/}/usr/share"

  # Evil flag (bug #919201)
  #filter-flags -fno-delete-null-pointer-checks

  # The ABI of media-libs/tg_owt breaks if the -DNDEBUG flag doesn't keep
  # the same state across both projects.
  # See https://bugs.gentoo.org/866055
  append-cppflags -DNDEBUG

  # https://github.com/telegramdesktop/tdesktop/issues/17437#issuecomment-1001160398
  use !libdispatch && append-cppflags -DCRL_FORCE_QT

  #export TDESKTOP_API_ID="17349"
  #export TDESKTOP_API_HASH="344583e45741c457fe1862106095a5eb"

  export TDESKTOP_API_ID="611335"
  export TDESKTOP_API_HASH="d524b414d21f4d37f08684c1df41ac9c"

  LDFLAGS="${LDFLAGS} -Wl,-z,stack-size=1024768" \
  cmake -B build -G "Unix Makefiles" \
    -D CMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -D CMAKE_INSTALL_BINDIR="bin" \
    -D CMAKE_INSTALL_LIBDIR="$(get_libdir)" \
    -D CMAKE_INSTALL_INCLUDEDIR="${INCDIR#/}" \
    -D CMAKE_INSTALL_DATAROOTDIR="${DPREFIX#/}/share" \
    -D CMAKE_INSTALL_DOCDIR="${DPREFIX#/}/share/doc" \
    -D CMAKE_BUILD_TYPE="MinSizeRel" \
    -D QT_VERSION_MAJOR=6 \
    -D CMAKE_DISABLE_PRECOMPILE_HEADERS=ON \
    -D CMAKE_DISABLE_FIND_PACKAGE_tl-expected=ON \
    -D CMAKE_DISABLE_FIND_PACKAGE_Qt6Quick=OFF \
    -D CMAKE_DISABLE_FIND_PACKAGE_Qt6QuickWidgets=OFF \
    -D CMAKE_DISABLE_FIND_PACKAGE_Qt6WaylandClient=ON \
    -D CMAKE_DISABLE_FIND_PACKAGE_Qt6WaylandCompositor=OFF \
    -D DESKTOP_APP_USE_LIBDISPATCH=$(usex 'libdispatch' ON OFF) \
    -D DESKTOP_APP_DISABLE_X11_INTEGRATION=$(usex !X ON OFF) \
    -D DESKTOP_APP_DISABLE_WAYLAND_INTEGRATION=ON \
    -D DESKTOP_APP_DISABLE_JEMALLOC=$(usex !jemalloc ON OFF) \
    -D DESKTOP_APP_DISABLE_CRASH_REPORTS=ON \
    -D DESKTOP_APP_USE_ENCHANT=$(usex 'enchant' ON OFF) \
    -D DESKTOP_APP_USE_PACKAGED_FONTS=$(usex !fonts ON OFF) \
    -D TDESKTOP_API_ID="${TDESKTOP_API_ID}" \
    -D TDESKTOP_API_HASH="${TDESKTOP_API_HASH}" \
    -D BUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  # FIX: required >10GB free space (it with headers precompile)
  DESTDIR="${ED}" cmake --build build --target ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'stest' && { bin/${PROG} --version || : die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || : die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz