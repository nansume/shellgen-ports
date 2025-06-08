#!/bin/sh
# Copyright (C) 2024-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-13 16:00 UTC, 2025-05-18 12:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# It fix - BUG: run-time fatal error: Segmentation fault
# It fix - BUG: Bus error - prog[qt5] start run-time failed
# TODO: required fix patch under ver. 1.10.3p2 (2022.02.18) and only after bump.

# https://git.alpinelinux.org/aports/tree/testing/twinkle/APKBUILD
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=twinkle
# http://data.gpo.zugaina.org/nest/net-voip/twinkle/twinkle-1.10.3.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="Softphone for voice over IP and IM communication using SIP"
HOMEPAGE="https://github.com/LubosD/twinkle https://twinkle.dolezel.info"
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
PN=${PN%[0-9]}
PV="1.10.3p2"  # 1.10.3-2022.02.18
PV="1.10.3"
SRC_URI="https://github.com/lubosd/${PN}/archive/master.tar.gz -> ${PN}-${PV}.tar.gz  # Ver: 1.10.3p2"
SRC_URI="
  https://github.com/LubosD/${PN}/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz  # Ver: 1.10.3
  https://git.alpinelinux.org/aports/plain/testing/twinkle/glibc.patch -> twinkle-pthread-mutex-np.patch
  http://data.gpo.zugaina.org/nest/net-voip/twinkle/files/twinkle-1.10.2-g729.patch
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
IUSE="+alsa -g729 -gsm +speex +zrtp +qt5 -dbus +static -shared -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-master"  # Ver: 1.10.3p2
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"   # Ver: 1.10.3
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
  "app-crypt/libb2  # deps python" \
  "dev-build/cmake3" \
  "#dev-cpp/commoncpp2" \
  "dev-db/sqlite3  # pre sqlite0, deps libsndfile" \
  "dev-lang/python3-12  # deps: glib74" \
  "dev-libs/ccrtp" \
  "dev-libs/expat  # icu,freetype" \
  "dev-libs/glib74  # pre: glib57" \
  "dev-libs/gmp  # deps tls" \
  "dev-libs/icu76  # pre icu59, deps qt5base" \
  "#dev-libs/libffi  # for glib" \
  "dev-libs/libgcrypt  # deps gnutls" \
  "dev-libs/libgpg-error  # deps gnutls" \
  "dev-libs/libxml2-1  # shared: libxml2-1, static: libxml2" \
  "dev-libs/libtasn1  # deps gnutls" \
  "dev-libs/libunistring  # deps gnutls" \
  "dev-libs/nettle  # deps gnutls" \
  "dev-libs/pcre2  # deps: glib74" \
  "dev-libs/openssl3" \
  "dev-libs/ucommon" \
  "dev-libs/zrtpcpp  # zrtp" \
  "dev-qt/qt5base15  # pre: qt5base0" \
  "dev-qt/qt5declarative15  # pre: qt5declarative0" \
  "dev-qt/qt5tools15  # pre: qt5tools0" \
  "#dev-util/byacc  # alternative a bison" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib  # deps libsndfile" \
  "media-libs/freetype  # fontconfig" \
  "media-libs/fontconfig" \
  "media-libs/flac  # deps libsndfile" \
  "media-libs/libogg  # deps libsndfile" \
  "media-libs/libvorbis  # deps libsndfile" \
  "media-libs/libsndfile" \
  "media-libs/mesa  # for opengl" \
  "media-libs/opus  # deps libsndfile" \
  "media-libs/speex" \
  "media-libs/speexdsp" \
  "media-sound/lame  # deps libsndfile" \
  "media-sound/mpg123  # deps libsndfile" \
  "net-libs/gnutls  # deps commoncpp2" \
  "#sys-apps/dbus  # Ver: 1.10.3p2 (optional)" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/bison" \
  "sys-devel/flex" \
  "sys-devel/gcc14" \
  "#sys-devel/lex  # alternative a flex" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/ncurses  # deps readline" \
  "sys-libs/readline8" \
  "sys-libs/zlib  # deps tls,zrtpcpp" \
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
  "x11-libs/libxdamage  # for opengl" \
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
  "x11-libs/libxt  # dbus (?no-required)" \
  "x11-libs/libxxf86vm" \
  "x11-libs/xcb-util  # ?for xcb, (?static)" \
  "x11-libs/xcb-util-cursor  # (?static)" \
  "x11-libs/xcb-util-image  # ?for xcb, (?static)" \
  "x11-libs/xcb-util-keysyms  # ?for xcb, (?static)" \
  "x11-libs/xcb-util-renderutil  # ?for xcb, (?static)" \
  "x11-libs/xcb-util-wm  # ?for xcb, (?static)" \
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
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  gpatch -p1 -E < "${FILESDIR}/${PN}"-pthread-mutex-np.patch  # compatible with Ver-1.10.3
  use 'g729' && patch -p1 -E < "${FILESDIR}/${PN}"-1.10.2-g729.patch

  mkdir -pm 0755 -- "${BUILD_DIR}/build/"
  cd "${BUILD_DIR}/build/" || die "builddir: not found... error"

  . runverb \
  cmake \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}/usr" \
    -DCMAKE_BUILD_TYPE="MinSizeRel" \
    -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DWITH_QT5=$(usex 'qt5' ON OFF) \
    -DWITH_DBUS=$(usex 'dbus' ON OFF) \
    -DWITH_ALSA=$(usex 'alsa' ON OFF) \
    -DWITH_G729=$(usex 'g729' ON OFF) \
    -DWITH_GSM=$(usex 'gsm' ON OFF) \
    -DWITH_ILBC=OFF \
    -DWITH_SPEEX=$(usex 'speex' ON OFF) \
    -DWITH_ZRTP=$(usex 'zrtp' ON OFF) \
    -DCMAKE_SKIP_RPATH="ON" \
    -DCMAKE_SKIP_INSTALL_RPATH="ON" \
    -Wno-dev \
    .. || die "Failed cmake build"

  make -j "$(nproc)" V=1 || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  test -d "usr/bin" && mv -v -n usr/bin -t .

  use 'stest' && { bin/${PN} --version || die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz