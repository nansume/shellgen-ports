#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-05-26 20:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/media-video/ffmpeg/ffmpeg-7.1.1-r1.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Complete solution to record, convert and stream audio and video. Includes libavcodec"
HOMEPAGE="https://ffmpeg.org/"
LICENSE="GPL-2+ | LGPL-2.1+"
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
PV="7.1"
SRC_URI="https://ffmpeg.org/releases/${PN}-${PV}.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-X -alsa -amf -amrenc -amr -appkit -bluray -bs2b -bzip2 -cdio -chromaprint -codec2 -cuda"
IUSE="${IUSE} -dav1d -doc -drm -dvd -fdk -flite -fontconfig -frei0r -fribidi -gcrypt -gme +gmp"
IUSE="${IUSE} -gnutls +gpl -gsm -iec61883 -ieee1394 -jack -jpeg2k -jpegxl -kvazaar -ladspa -lame"
IUSE="${IUSE} -lcms -libaom -libaribb24 -libass -libcaca -libilbc -liblc3 -libplacebo -librtmp"
IUSE="${IUSE} -libsoxr -libtesseract -lv2 -lzma -modplug -npp -nvenc -openal -opencl -opengl"
IUSE="${IUSE} -openh264 -openmpt +openssl +opus -postproc -pulseaudio -qrcode -qsv -quirc -rabbitmq"
IUSE="${IUSE} -rav1e -rubberband -samba -sdl -shaderc -snappy -sndio -speex -srt -ssh -svg -svt-av1"
IUSE="${IUSE} -theora -truetype -twolame +v4l -vaapi -vdpau -vidstab -vmaf -vorbis +vpx -vulkan"
IUSE="${IUSE} -webp -x264 -x265 -xml -xvid -zeromq -zimg +zlib -zvbi -chromium -soc +encoders"
IUSE="${IUSE} +iconv +ffplay (-asm) +rpath -static -static-libs +shared (+musl) +stest +strip"
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
  "#dev-lang/nasm  # no support x32" \
  "dev-libs/expat  # deps fontconfig" \
  "dev-libs/gmp  # deps ssl (optional)" \
  "dev-libs/openssl3" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib" \
  "media-libs/freetype  # deps fontconfig" \
  "media-libs/fontconfig  # same how in mplayer,mpv,qmplay2" \
  "#media-libs/libass  # in mpv,qmplay2 same" \
  "media-libs/libv4l" \
  "media-libs/libvpx1" \
  "media-libs/opus" \
  "sys-devel/binutils" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps ssl (optional), zlib[minizip]" \
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
  if use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')
  use 'x32' && append-flags -ffast-math
  use 'x32' && USE="${USE} -asm"  # is here asm no-support x32

  CC="gcc" CXX="g++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # test big-endian or little-endian, required replace od --> xxd
  # busybox nocompat: od: unrecognized option: t
  sed -e 's|^\(od -t x1 \)|#\1|' -i configure

  ./configure \
    --prefix="/usr" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --incdir="${INCDIR}" \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --enable-hardcoded-tables \
    $(usex !asm --disable-asm) \
    $(usex 'gpl' --enable-gpl) \
    $(usex 'gpl' --enable-version3) \
    $(use_enable 'ffplay') \
    $(usex 'encoders' --disable-encoders) \
    --disable-filters \
    $(usex !drm --disable-libdrm) \
    $(use_enable 'v4l' libv4l2) \
    $(use_enable 'iconv') \
    $(use_enable 'libass') \
    --disable-lzma \
    $(use_enable 'zlib') \
    $(use_enable 'openssl') \
    $(usex 'gmp' --enable-gmp) \
    $(use_enable 'vpx' libvpx) \
    $(use_enable 'opus' libopus) \
    --disable-postproc \
    --disable-indev=lavfi \
    --disable-indev=oss \
    $(usex !v4l --disable-indev=v4l2) \
    --disable-outdev=oss \
    $(usex !v4l --disable-outdev=v4l2) \
    --disable-doc \
    --disable-debug \
    --enable-shared \
    $(use_enable 'static-libs' static) \
    $(use_enable 'rpath') \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" install || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'stest' && { bin/${PN} -version || die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz