#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-04-05 19:00 UTC - last change
# Build with useflag: static +static-libs/+shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# BUG: Found Doxygen: /bin/doxygen (found version `1.13.2`) found components: doxygen missing components: dot

# http://data.gpo.zugaina.org/nest/media-libs/mediastreamer2/mediastreamer2-5.3.86.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="SIP library supporting voice/video calls and text messaging"
HOMEPAGE="https://gitlab.linphone.org/BC/public/liblinphone"
LICENSE="AGPL-3"
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
PV="5.3.110"
PV="4.4.0"
SRC_URI="https://gitlab.linphone.org/BC/public/${PN}/-/archive/${PV}/${PN}-${PV}.tar.bz2"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-debug -doc -ldap +lime -qrcode -test +tools -static-libs +shared (+musl) +stest +strip"
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
  "dev-libs/gmp  # deps libsrtp" \
  "dev-libs/jsoncpp" \
  "dev-libs/libffi  # deps python3" \
  "dev-libs/libxml2-1  # deps bzrtp" \
  "#dev-libs/lime  # not found" \
  "dev-libs/openssl3  # deps libsrtp" \
  "dev-libs/xerces-c" \
  "dev-python/py38-pystache" \
  "dev-python/py38-setuptools" \
  "dev-python/py38-six" \
  "#dev-vcs/git  # replace to fake" \
  "dev-util/cmake" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib  # alsa" \
  "media-libs/libjpeg-turbo3  # jpeg" \
  "media-libs/libvpx0" \
  "media-libs/mediastreamer2  # required: mediastreamer2[zrtp,srtp,jpeg]" \
  "media-libs/opus" \
  "net-libs/bctoolbox" \
  "net-libs/bzrtp" \
  "net-libs/libsrtp2" \
  "net-libs/mbedtls  # deps bctoolbox" \
  "net-libs/ortp" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps libsrtp,soci" \
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
  if use !shared && use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # fix incapability to detect jsoncpp
  sed -e '/json\/json.h/s|<|<jsoncpp/|' -i \
   include/linphone/flexi-api-client.h \
   src/account_creator/flexi-api-client.cpp \
   tester/account_creator_flexiapi_tester.cpp \
   tester/flexiapiclient-tester.cpp \
   tester/remote-provisioning-tester.cpp \
   || : die "sed failed for json"
  # rename target, name is used further in linking with linphone
  sed -e '/set(JsonCPP_TARGET/s|_lib||' -i cmake/FindJsonCPP.cmake || : die "sed failed for FindJsonCPP.cmake"

  cmake -B build -G "Unix Makefiles" \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}/usr" \
    -DCMAKE_INSTALL_BINDIR="${EPREFIX%/}/bin" \
    -DCMAKE_INSTALL_LIBDIR="${EPREFIX%/}/$(get_libdir)" \
    -DCMAKE_INSTALL_INCLUDEDIR="${INCDIR}" \
    -DCMAKE_INSTALL_DATAROOTDIR="${DPREFIX}/share" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DENABLE_CONSOLE_UI=YES \
    -DENABLE_DEBUG_LOGS=$(usex 'debug') \
    -DENABLE_DOC=$(usex 'doc') \
    -DENABLE_LDAP=$(usex 'ldap') \
    -DENABLE_LIME_X3DH=$(usex 'lime') \
    -DENABLE_QRCODE=$(usex 'qrcode') \
    -DENABLE_STRICT=NO \
    -DENABLE_TOOLS=$(usex 'tools') \
    -DENABLE_UNIT_TESTS=$(usex 'test') \
    -DBUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  DESTDIR="${ED}" cmake --build build --target ${INSTALL_OPTS} -j "$(nproc)" || : die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  # path is needed for LibLinphoneConfig.cmake
  # build manager doesn't install empty dirs
  > $(get_libdir)/liblinphone/plugins/.keepdir

  ldd "$(get_libdir)/${PN}.so" || die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz