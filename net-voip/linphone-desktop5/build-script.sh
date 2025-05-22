#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-05-17 20:00 UTC - last change
# Build with useflag: +static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/nest/net-voip/linphone-desktop/linphone-desktop-5.2.6.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="A free VoIP and video softphone based on the SIP protocol"
HOMEPAGE="https://gitlab.linphone.org/BC/public/linphone-desktop"
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
PN=${PN%[0-9]}
PV="5.2.6"
PV="5.1.2"
PV="5.0.18"
SRC_URI="
  https://gitlab.linphone.org/BC/public/${PN}/-/archive/${PV}/${PN}-${PV}.tar.bz2
  http://data.gpo.zugaina.org/nest/net-voip/linphone-desktop/files/linphone-desktop-5.2.4-FindBCToolbox.patch
  http://data.gpo.zugaina.org/nest/net-voip/linphone-desktop/files/linphone-desktop-5.2.4-FindMediastreamer2.patch
  http://data.gpo.zugaina.org/nest/net-voip/linphone-desktop/files/linphone-desktop-5.2.4-FindLibLinphone.patch
  http://data.gpo.zugaina.org/nest/net-voip/linphone-desktop/files/linphone-desktop-5.2.4-FindBelcard.patch
  http://data.gpo.zugaina.org/nest/net-voip/linphone-desktop/files/linphone-desktop-5.2.4-spellchecker.patch
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
IUSE="-ldap -qrcode -static +shared -doc (+musl) +stest +strip"
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
  "app-text/doxygen1" \
  "dev-cpp/belr" \
  "#dev-cpp/xsd  # not found" \
  "dev-db/soci" \
  "dev-db/sqlite3  # deps bzrtp" \
  "dev-lang/python3-8" \
  "dev-libs/expat  # deps python3" \
  "dev-libs/belcard" \
  "dev-libs/belle-sip" \
  "dev-libs/cxx-boost  # deps soci" \
  "dev-libs/glib74" \
  "dev-libs/gmp  # deps libsrtp" \
  "dev-libs/icu64" \
  "dev-libs/jsoncpp" \
  "dev-libs/libffi  # deps python3" \
  "dev-libs/liblinphone" \
  "dev-libs/libxml2-1  # deps bzrtp" \
  "dev-libs/libxslt" \
  "dev-libs/pcre2  # for glib74" \
  "dev-libs/openssl3" \
  "#dev-libs/lime  # not found" \
  "#dev-libs/qtkeychain  # not found" \
  "dev-libs/openssl3  # deps libsrtp" \
  "dev-libs/xerces-c" \
  "dev-qt/qt5base15" \
  "dev-qt/qt5declarative15" \
  "dev-qt/qt5svg15" \
  "dev-qt/qt5tools15" \
  "dev-python/py38-pystache" \
  "dev-python/py38-setuptools" \
  "dev-python/py38-six" \
  "#dev-vcs/git  # replace to fake" \
  "#dev-util/byacc  # alternative a bison" \
  "dev-util/cmake" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib  # alsa" \
  "media-libs/freetype  # fontconfig" \
  "media-libs/fontconfig" \
  "media-libs/giflib" \
  "media-libs/gstreamer1" \
  "media-libs/gst-plugins-base1" \
  "media-libs/libjpeg-turbo3  # jpeg" \
  "media-libs/libvpx0" \
  "media-libs/mediastreamer2  # required: mediastreamer2[zrtp,srtp,jpeg]" \
  "media-libs/mesa  # for opengl" \
  "media-libs/opus" \
  "net-libs/bctoolbox" \
  "net-libs/bzrtp" \
  "net-libs/libsrtp2" \
  "net-libs/mbedtls  # deps bctoolbox" \
  "net-libs/ortp" \
  "sys-apps/dbus" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "#sys-devel/lex  # alternative a flex" \
  "sys-devel/make" \
  "#sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps libsrtp,soci" \
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
  "x11-libs/libxrandr" \
  "x11-libs/libxrender" \
  "x11-libs/libxshmfence  # for ?opengl" \
  "x11-libs/libxv  # optional" \
  "x11-libs/libxt  # dbus" \
  "x11-libs/libxxf86vm  # for ?opengl" \
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

  #patch -p1 -E < "${FILESDIR}"/"${PN}"-5.2.4-FindBCToolbox.patch
  # fix incorrect use of get_target_property
  #patch -p1 -E < "${FILESDIR}"/"${PN}"-5.2.4-FindMediastreamer2.patch
  # change path to BCToolbox, include config
  #patch -p1 -E < "${FILESDIR}"/"${PN}"-5.2.4-FindLibLinphone.patch
  # change path to BelCard
  #patch -p1 -E < "${FILESDIR}"/"${PN}"-5.2.4-FindBelcard.patch
  # remove spellchecker from UI
  #patch -p1 -E < "${FILESDIR}"/"${PN}"-5.2.4-spellchecker.patch

  # don`t build ispell, don`t build rpm, don`t install qt.conf,
  # respect DESTDIR, correct include path, commend out spellchecker sources
  sed \
   -e '/if(NOT APPLE AND NOT WIN32)/s|APPLE|UNIX|' \
   -e '/add_subdirectory(build)/d' \
   -e '/deployqt_hack/d' \
   -e 's|${CMAKE_INSTALL_PREFIX}|\\$ENV{DESTDIR}\/${CMAKE_INSTALL_PREFIX}|g' \
   -e '/install(DIRECTORY/s|include"|include/"|' \
   -e '/spell-checker/s|^|#|' \
   -i linphone-app/CMakeLists.txt \
   || die "sed for CMakeLists.txt failed"

  # don`t install ispell dictionaries, don`t build AppImage, don`t install qt.conf
  sed \
   -e '/ISpell_SOURCE_DIR/d' \
   -e '/{ENABLE_APP_PACKAGING}/s|}|_}|' \
   -e "/install(FILES.*qt.conf/d" \
   -i linphone-app/cmake_builder/linphone_package/CMakeLists.txt \
   || die "sed failed for linphone_package/CMakeLists.txt"

  # remove SpellChecker component
  sed '/SpellChecker/d' -i linphone-app/src/app/App.cpp || die "sed failed for App.cpp"

  cmake -B build -G "Unix Makefiles" \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -DCMAKE_INSTALL_BINDIR="bin" \
    -DCMAKE_INSTALL_LIBDIR="$(get_libdir)" \
    -DCMAKE_INSTALL_INCLUDEDIR="${INCDIR#/}" \
    -DCMAKE_INSTALL_DATAROOTDIR="${DPREFIX#/}/share" \
    -DCMAKE_INSTALL_DOCDIR="${DPREFIX#/}/share/doc" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DLINPHONEAPP_VERSION="${PV}" \
    -DLINPHONE_OUTPUT_DIR="/" \
    -DENABLE_APP_PACKAGING=YES \
    -DLINPHONE_QT_ONLY=YES \
    -DENABLE_APP_EXPORT_PLUGIN=NO \
    -DENABLE_BUILD_VERBOSE=ON \
    -DENABLE_CONSOLE_UI=ON \
    -DENABLE_DAEMON=ON \
    -DENABLE_LDAP=$(usex 'ldap' ON OFF) \
    -DENABLE_QRCODE=$(usex 'qrcode' ON OFF) \
    -DENABLE_QT_KEYCHAIN=NO \
    -DENABLE_STRICT=OFF \
    -DENABLE_UPDATE_CHECK=OFF \
    -DENABLE_BUILD_APP_PLUGINS=OFF \
    -DBUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  DESTDIR="${ED}" cmake --build build --target ${INSTALL_OPTS} -j "$(nproc)" || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  test -d "usr/bin" && mv -v -n usr/bin -t .

  # fix: cmake wrong the pkgconfig
  grep '${prefix}' < $(get_libdir)/pkgconfig/${PN}.pc
  sed -e 's|${prefix}||' -i $(get_libdir)/pkgconfig/*${PN}*.pc

  use 'stest' && { bin/${PROG} --version || : die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || : die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz