#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-05-19 18:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-qt/qtbase/qtbase-6.9.0-r1.ebuild
# https://crux.nu/ports/crux-3.7/opt/qt6-base/Pkgfile
# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=qt6-base-git

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="Cross-platform application development framework"
HOMEPAGE="https://www.qt.io/"
LICENSE="GPL3 LGPL3 FDL custom"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
SPN="qtbase-everywhere-src"
XPN=${XPN:-$PN}
PV="6.9.0"
SRC_URI="
  https://download.qt.io/official_releases/qt/${PV%.*}/${PV}/submodules/${SPN}-${PV}.tar.xz
  http://data.gpo.zugaina.org/gentoo/dev-qt/qtbase/files/qtbase-6.5.2-no-symlink-check.patch
  http://data.gpo.zugaina.org/gentoo/dev-qt/qtbase/files/qtbase-6.6.1-forkfd-childstack-size.patch
  http://data.gpo.zugaina.org/gentoo/dev-qt/qtbase/files/qtbase-6.9.0-no-direct-extern-access.patch
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
IUSE="+ssl -udev -zstd"  # global
IUSE="${IUSE} +icu -journald +syslog -nls"  # core
IUSE="${IUSE} +concurrent +dbus +gui +network +sql +xml"  # modules
IUSE="${IUSE} +X -accessibility +eglfs +evdev +gles2-only -libinput"  # gui
IUSE="${IUSE} +opengl -renderdoc -tslib -vulkan -wayland +widgets"  # gui
IUSE="${IUSE} -brotli -gssapi -libproxy -sctp"  # network
IUSE="${IUSE} -mysql -oci8 -odbc -postgres +sqlite"  # sql
IUSE="${IUSE} +cups -gtk"  # widgets
IUSE="${IUSE} -static-libs +shared -doc (+musl) +stest +strip"
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
CMAKE_PREFIX_PATH="/${LIB_DIR}/cmake"
PROG=${PN}
LC_ALL="C.UTF-8"

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
  "app-misc/ca-certificates  # openssl" \
  "dev-build/samurai  # alternative for ninja" \
  "dev-lang/perl  # optional" \
  "#dev-lang/python3-8  # for glib new version [pre: python3-6]" \
  "dev-lang/ruby26  # past ruby26" \
  "dev-libs/expat  # icu,freetype" \
  "dev-libs/glib74" \
  "dev-libs/gmp  # for ssl" \
  "dev-libs/icu64" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libxml2-1" \
  "dev-libs/libxslt" \
  "dev-libs/pcre2  # for glib74" \
  "dev-libs/openssl3" \
  "#dev-perl/digest-perl-md5" \
  "#dev-perl/perl-file-spec  # no required, it part perl." \
  "#dev-perl/perl-getopt-long  # no required, it part perl." \
  "#dev-util/byacc  # alternative a bison" \
  "dev-util/cmake" \
  "dev-util/gperf" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib" \
  "media-libs/freetype  # fontconfig" \
  "media-libs/fontconfig" \
  "media-libs/giflib" \
  "media-libs/gstreamer1" \
  "media-libs/gst-plugins-base1" \
  "#media-libs/libjpeg-turbo3" \
  "media-libs/mesa  # for opengl" \
  "net-print/cups" \
  "sys-apps/dbus" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/bison" \
  "sys-devel/flex" \
  "sys-devel/gcc9" \
  "#sys-devel/lex  # alternative a flex" \
  "sys-devel/make" \
  "#sys-devel/patch" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib  # for ssl" \
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

  #export QT6DIR="${BUILD_DIR}"
  export LD_LIBRARY_PATH="${BUILD_DIR}/build/$(get_libdir):${LD_LIBRARY_PATH}"
  #export QT6PREFIX="/"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/qtbase-6.5.2-no-symlink-check.patch
  patch -p1 -E < "${FILESDIR}"/qtbase-6.6.1-forkfd-childstack-size.patch
  patch -p1 -E < "${FILESDIR}"/qtbase-6.9.0-no-direct-extern-access.patch

  #cmake -B build -G "Unix Makefiles" \
  cmake -B build -G Ninja \
    -D CMAKE_INSTALL_PREFIX="${EPREFIX%/}/" \
    -D CMAKE_INSTALL_LIBDIR="/$(get_libdir)" \
    -D CMAKE_INSTALL_DATAROOTDIR="/usr/share" \
    -D CMAKE_BUILD_TYPE="Release" \
    -D CMAKE_CXX_FLAGS_RELEASE="${CXXFLAGS}" \
    -D CMAKE_C_FLAGS_RELEASE="${CFLAGS}" \
    -D CMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
    -D BUILD_WITH_PCH=OFF \
    -D INSTALL_BINDIR=$(get_libdir)/qt6/bin \
    -D INSTALL_PUBLICBINDIR=bin \
    -D INSTALL_LIBDIR="$(get_libdir)" \
    -D INSTALL_LIBEXECDIR=$(get_libdir)/qt6 \
    -D INSTALL_DOCDIR=usr/share/doc/qt6 \
    -D INSTALL_ARCHDATADIR=$(get_libdir)/qt6 \
    -D INSTALL_DATADIR=usr/share/qt6 \
    -D INSTALL_INCLUDEDIR=usr/include/qt6 \
    -D INSTALL_MKSPECSDIR=$(get_libdir)/qt6/mkspecs \
    -D INSTALL_PLUGINSDIR=$(get_libdir)/qt6/plugins \
    -D INSTALL_QMLDIR=$(get_libdir)/qt6/qml \
    -D INSTALL_SYSCONFDIR=/etc/xdg \
    -D INSTALL_TRANSLATIONSDIR=usr/share/qt6/translations \
    -D INSTALL_EXAMPLESDIR=usr/share/doc/qt6/examples \
    -D QT_FEATURE_xcb=ON \
    -D QT_FEATURE_xkbcommon_x11=ON \
    -D QT_FEATURE_system_xcb_xinput=ON \
    -D QT_FEATURE_evdev=OFF \
    -D QT_FEATURE_widgets=ON \
    -D QT_FEATURE_journald=OFF \
    -D QT_FEATURE_syslog=OFF \
    -D QT_FEATURE_libproxy=OFF \
    -D QT_FEATURE_no_direct_extern_access=OFF \
    -D QT_FEATURE_openssl_linked=ON \
    -D QT_FEATURE_dbus_linked=ON \
    -D QT_FEATURE_system_zlib=OFF \
    -D QT_FEATURE_system_harfbuzz=OFF \
    -D QT_FEATURE_system_sqlite=OFF \
    -D QT_FEATURE_system_pcre2=OFF \
    -D QT_FEATURE_system_freetype=OFF \
    -D QT_UNITY_BUILD=ON \
    -D QT_FEATURE_concurrent=ON \
    -D QT_FEATURE_dbus=ON \
    -D QT_FEATURE_gui=ON \
    -D QT_FEATURE_network=ON \
    -D QT_FEATURE_sql=ON \
    -D QT_FEATURE_testlib=ON \
    -D QT_FEATURE_xml=ON \
    -D QT_INTERNAL_AVOID_OVERRIDING_SYNCQT_CONFIG=ON \
    -D QT_BUILD_TESTS_BY_DEFAULT=OFF \
    -D QT_FEATURE_reduce_relocations=OFF \
    -D QT_FEATURE_relocatable=OFF \
    -D QT_FEATURE_androiddeployqt=OFF \
    -D QT_FEATURE_glibc_fortify_source=OFF \
    -D QT_FEATURE_intelcet=OFF \
    -D QT_FEATURE_libcpp_hardening=OFF \
    -D QT_FEATURE_libstdcpp_assertions=OFF \
    -D QT_FEATURE_relro_now_linker=OFF \
    -D QT_FEATURE_stack_clash_protection=OFF \
    -D QT_FEATURE_stack_protector=OFF \
    -D QT_FEATURE_trivial_auto_var_init_pattern=OFF \
    -D QT_INTERNAL_AVOID_OVERRIDING_SYNCQT_CONFIG=ON \
    -D QT_FEATURE_rpath=OFF \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  #DESTDIR="${ED}" cmake --build build --target ${INSTALL_OPTS} -j "$(nproc)" || die "make install... error"

  ninja -j "$(nproc)" -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${ED}" cmake --install build $(usex 'strip' --strip) || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  # fix: cmake wrong the pkgconfig
  grep '${prefix}' < $(get_libdir)/pkgconfig/Qt6Core.pc
  sed -e 's|${prefix}||' -i $(get_libdir)/pkgconfig/Qt6*.pc

  ldd "$(get_libdir)"/libQt6Core.so || die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz