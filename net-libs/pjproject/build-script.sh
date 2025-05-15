#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-05-03 10:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-libs/pjproject/pjproject-2.15.1-r1.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Open source SIP, Media, and NAT Traversal Library"
HOMEPAGE="https://github.com/pjsip/pjproject https://www.pjsip.org/"
LICENSE="GPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PV="2.15.1"
SRC_URI="
  https://github.com/pjsip/pjproject/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/net-libs/pjproject/files/pjproject-2.13.1-r1-config_site.h
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
CODEC_FLAGS="-g711 -g722 -g7221 -gsm -ilbc +speex -l16"
VIDEO_FLAGS="-sdl -ffmpeg -v4l2 -openh264 -libyuv -vpx"
SOUND_FLAGS="+alsa -portaudio"
IUSE="-amr -debug -epoll -examples +opus -resample -silk +srtp +ssl +static-libs +webrtc"
IUSE="${IUSE} ${CODEC_FLAGS} -g729 ${VIDEO_FLAGS} ${SOUND_FLAGS}"
IUSE="${IUSE} +shared -doc (+musl) +stest +strip"
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
PROG="pjsua"

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
  "dev-libs/gmp  # deps openssl" \
  "dev-libs/openssl3" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib" \
  "media-libs/libogg  # deps speex" \
  "media-libs/speex" \
  "media-libs/speexdsp  # deps speex" \
  "media-libs/opus" \
  "net-libs/libsrtp2" \
  "sys-apps/util-linux" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps openssl" \
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

  use 'debug' || append-cflags -DNDEBUG=1

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  #rm configure || die "Unable to remove unwanted wrapper"
  #mv aconfigure.ac configure.ac || die "Unable to rename configure script source"
  #eautoreconf

  cp "${FILESDIR}/pjproject-2.13.1-r1-config_site.h" "pjlib/include/pj/config_site.h" \
   || die "Unable to create config_site.h"

  sed \
    -re "s/^#define[[:space:]]+PJMEDIA_HAS_VIDEO[[:space:]].*/#define PJMEDIA_HAS_VIDEO 0/" \
    -i "pjlib/include/pj/config_site.h"

  printf %s\\n "CHOST='$(tc-chost)'"  # BUG: chost is here rightly, error into self package.

  LD="${CXX}" \
  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-video \
    $(usex 'alsa' '' --disable-sound) \
    $(usex 'amr' '' --disable-opencore-amr) \
    $(usex 'epoll' '' --disable-epoll) \
    $(usex 'opus' '' --disable-opus) \
    $(usex 'portaudio' '' --disable-ext-sound) \
    $(usex 'resample' '' --disable-libsamplerate) \
    $(usex 'resample' '' --disable-resample-dll) \
    $(usex 'resample' '' --disable-resample) \
    $(usex 'silk' '' --disable-silk) \
    $(usex 'speex' '' --disable-speex-aec) \
    $(usex 'ssl' '' --disable-ssl) \
    $(usex 'webrtc' '' --disable-libwebrtc) \
    $(use_with 'gsm' external-gsm) \
    $(use_with 'portaudio' external-pa) \
    $(use_with 'speex' external-speex) \
    $(usex 'srtp' --with-external-srtp --disable-libsrtp) \
    $(usex 'g711' '' --disable-g711-codec) \
    $(usex 'g722' '' --disable-g722-codec) \
    $(usex 'g7221' '' --disable-g7221-codec) \
    $(usex 'gsm' '' --disable-gsm-codec) \
    $(usex 'ilbc' '' --disable-ilbc-codec) \
    $(usex 'speex' '' --disable-speex-codec) \
    $(usex 'l16' '' --disable-l16-codec) \
    $(usex 'g729' '' --disable-bcg729) \
    $(usex 'sdl' '' --disable-sdl) \
    $(usex 'ffmpeg' '' --disable-ffmpeg) \
    $(usex 'v4l2' '' --disable-v4l2) \
    $(usex 'openh264' '' --disable-openh264) \
    $(usex 'libyuv' '' --disable-libyuv) \
    $(usex 'vpx' '' --disable-vpx) \
    $(usex 'libyuv' --with-external-yuv) \
    --enable-shared \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" install || die "make install... error"

  mkdir -pm 0755 -- "${ED}"/bin/
  mv -n pjsip-apps/bin/pjsua-* "${ED}"/bin/pjsua
  mv -n pjsip-apps/bin/pjsystest-* "${ED}"/bin/pjsystest

  if use 'examples'; then
    insinto "/usr/share/doc/${PN}-${PV}/examples"
    doins -r pjsip-apps/src/samples
  fi

  cd "${ED}/" || die "install dir: not found... error"

  use 'static-libs' || rm -- "$(get_libdir)"/*.a || die "Error removing static archives"

  : strip --verbose --strip-all "bin/"* "$(get_libdir)/"*.so
  use 'strip' && pkg-strip

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'stest' && { bin/${PROG} --version || die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz