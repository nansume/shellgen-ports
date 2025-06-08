#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-05-29 14:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/media-libs/tg_owt/tg_owt-0_pre20250515.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="WebRTC build for Telegram"
HOMEPAGE="https://github.com/desktop-app/tg_owt"
LICENSE="BSD"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
SPN="tg_owt"
PV="20250515"  # 0pre20250515
TG_OWT_COMMIT="232ec410502e773024e8d83cfae83a52203306c0"  # 0pre20250515
LIBYUV_COMMIT="04821d1e7d60845525e8db55c7bcd41ef5be9406"
LIBSRTP_COMMIT="a566a9cfcd619e8327784aa7cff4a1276dc1e895"
HASH3=${LIBYUV_COMMIT}
SRC_URI="
  https://github.com/desktop-app/tg_owt/archive/${TG_OWT_COMMIT}.tar.gz -> ${SPN}-${PV}.tar.gz
  https://gitlab.com/chromiumsrc/libyuv/-/archive/${HASH3}/libyuv-${HASH3}.tar.bz2 -> libyuv-${PV}.tar.bz2
  https://github.com/cisco/libsrtp/archive/${LIBSRTP_COMMIT}.tar.gz -> libsrtp-${PV}.tar.gz
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
IUSE="-screencast +X -static -static-libs +shared -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${SPN}-${TG_OWT_COMMIT}"
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
  "dev-build/cmake4" \
  "dev-build/samurai  # alternative for ninja" \
  "dev-cpp/abseil-cpp1" \
  "dev-lang/python3-10  # required" \
  "dev-libs/crc32c" \
  "dev-libs/expat  # deps ffmpeg,python" \
  "#dev-libs/glib74  # screencast?" \
  "dev-libs/gmp  # deps ssl" \
  "#dev-libs/jsoncpp  # deps protobuf" \
  "#dev-libs/libffi  # screencast?" \
  "#dev-libs/pcre2  # screencast?" \
  "dev-libs/protobuf" \
  "dev-libs/openssl3" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib" \
  "media-libs/freetype  # deps fontconfig" \
  "media-libs/fontconfig  # same how in mplayer,mpv,qmplay2" \
  "media-libs/libv4l" \
  "media-libs/libjpeg-turbo3" \
  "media-libs/libvpx1" \
  "media-libs/mesa  # for opengl" \
  "media-libs/openh264" \
  "media-libs/opus" \
  "media-video/ffmpeg7" \
  "#media-video/pipewire  # it missing | screencast?" \
  "#net-libs/libsrtp2  # bundled" \
  "sys-devel/binutils" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps ssl" \
  "x11-base/xorg-proto" \
  "#x11-libs/libdrm  # screencast?" \
  "x11-libs/libice" \
  "#x11-libs/libpciaccess  # screencast?" \
  "#x11-libs/libvdpau  # screencast?" \
  "x11-libs/libsm" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxcomposite" \
  "x11-libs/libxdamage  # for ?opengl" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxfixes" \
  "x11-libs/libxi" \
  "x11-libs/libxrandr" \
  "x11-libs/libxrender" \
  "x11-libs/libxshmfence  # screencast?" \
  "x11-libs/libxtst" \
  "#x11-libs/libxxf86vm  # screencast?" \
  "#x11-misc/util-macros" \
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

  for PF in *.tar.gz *.tar.bz2; do
    case ${PF} in '*'.tar.*) continue;; *.tar.gz) ZCOMP="gunzip";; *.tar.bz2) ZCOMP="bunzip2";; esac
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done
  mv -T "${WORKDIR}/libyuv-${LIBYUV_COMMIT}" "${BUILD_DIR}/src/third_party/libyuv" || die
  mv -T "${WORKDIR}/libsrtp-${LIBSRTP_COMMIT}" "${BUILD_DIR}/src/third_party/libsrtp" || die

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  # Defined by -DCMAKE_BUILD_TYPE=Release, avoids crashes
  # See https://bugs.gentoo.org/754012
  append-cppflags '-DNDEBUG'

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # The sources for these aren't available, avoid needing them
  sed -e '/include(cmake\/libcrc32c.cmake)/d' \
   -e '/include(cmake\/libabsl.cmake)/d' -i CMakeLists.txt || die

  # "lol" said the scorpion, "lmao"
  sed -i '/if (BUILD_SHARED_LIBS)/{n;n;s/WARNING/DEBUG/}' CMakeLists.txt || die

  # FIX: add missing headers for musl libc.
  sed -e '/^#include <algorithm>$/a #include <cstdint>' -i src/modules/audio_coding/neteq/reorder_optimizer.cc

  cmake -B build -G Ninja \
    -D CMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -D CMAKE_INSTALL_LIBDIR="$(get_libdir)" \
    -D CMAKE_INSTALL_INCLUDEDIR="${INCDIR#/}" \
    -D CMAKE_INSTALL_DATAROOTDIR="${DPREFIX#/}/share" \
    -D CMAKE_BUILD_TYPE="Release" \
    -D TG_OWT_USE_X11=$(usex 'X' ON OFF) \
    -D TG_OWT_USE_PIPEWIRE=$(usex 'screencast' ON OFF) \
    -D BUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  ninja -j "$(nproc)" -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${ED}" cmake --install build $(usex 'strip' --strip) || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  # Save about 15MB of useless headers
  rm -r "usr/include/tg_owt/rtc_base/third_party" || die
  rm -r "usr/include/tg_owt/common_audio/third_party" || die
  rm -r "usr/include/tg_owt/modules/third_party" || die
  rm -r "usr/include/tg_owt/third_party" || die

  # Install a few headers anyway, as required by net-im/telegram-desktop...
  # headers
  set -- third_party/libyuv/include rtc_base/third_party/sigslot
  set -- ${@} rtc_base/third_party/base64

  for dir in ${@}; do
    cd "${BUILD_DIR}/src/${dir}" || die
    find -type f -name "*.h" -exec install -Dm644 '{}' "${ED}/usr/include/tg_owt/${dir}/{}" \; || die
    cd "${ED}/" || die
  done

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  ldd "$(get_libdir)"/lib${SPN}.so || die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz