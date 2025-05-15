#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-31 20:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX AR PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Media player based on MPlayer and mplayer2"
HOMEPAGE="https://mpv.io/"
LICENSE="LGPL-2.1+ GPL-2+ BSD ISC samba? ( GPL-3+ )"
DOCS="RELEASE_NOTES README.md DOCS/client-api-changes.rst DOCS/interface-changes.rst"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="0.28.2"
PV="0.27.2"
WAF_PV="1.9.8"
SRC_URI="
  https://github.com/mpv-player/mpv/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz
  http://shellgen.mooo.com/pub/distfiles/${PN}-0.19.0-make-ffmpeg-version-check-non-fatal.patch
  http://shellgen.mooo.com/pub/distfiles/${PN}-0.25.0-fix-float-comparisons-in-tests.patch
  https://waf.io/waf-${WAF_PV}
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
IUSE="-static -static-libs +shared -doc (+musl) +stest +strip"
IUSE="${IUSE} +alsa -aqua -archive -bluray -cdda +cli -coreaudio -cplugins -cuda -doc +drm -dvb"
IUSE="${IUSE} -dvd -egl -encode -gbm +iconv -jack +javascript -jpeg -lcms +libass -libav -libcaca"
IUSE="${IUSE} +libmpv +lua -luajit -openal +opengl -oss -pulseaudio -raspberry-pi -rubberband"
IUSE="${IUSE} -samba -sdl -selinux -test -tools +uchardet -v4l -vaapi -vdpau -wayland +X +xv +zlib"
IUSE="${IUSE} -zsh-completion +optimize"
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
  "#app-arch/libarchive" \
  "app-i18n/uchardet  # iconv?" \
  "dev-lang/lua51" \
  "#dev-lang/luajit  # replace to dev-lang/luajit2" \
  "#dev-lang/perl  # optional" \
  "dev-lang/python38  for glib new version" \
  "dev-lang/mujs  # javascript?" \
  "dev-libs/expat  # freetype,libass,python" \
  "dev-libs/fribidi  # deps libass" \
  "dev-libs/libffi  # deps python" \
  "dev-python/docutils" \
  "#dev-python/rst2pdf  # doc?" \
  "dev-util/pkgconf" \
  "media-fonts/liberation-fonts  # deps libass" \
  "media-libs/alsa-lib" \
  "media-libs/freetype  # fontconfig" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz1  # deps libass" \
  "#media-libs/lcms" \
  "media-libs/libass" \
  "#media-libs/libcaca" \
  "media-libs/libjpeg-turbo1" \
  "media-libs/mesa  # mesa[egl]" \
  "#media-libs/sdl2  # sdl?" \
  "media-video/ffmpeg4" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "#sys-kernel/linux-headers-musl  # v4l?" \
  "sys-libs/musl" \
  "sys-libs/zlib  # zlib?,python" \
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
  "x11-libs/libxinerama" \
  "x11-libs/libxrandr" \
  "x11-libs/libxrender" \
  "x11-libs/libxv  # optional" \
  "x11-libs/libxscrnsaver" \
  "x11-libs/libxshmfence" \
  "x11-libs/libxxf86vm" \
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
  inherit flag-o-matic gnome2-utils toolchain-funcs waf-utils xdg-utils xdg install-functions

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc" CXX="c++" AR="ar"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  gpatch -p1 -E < "${FILESDIR}/${PN}-0.19.0-make-ffmpeg-version-check-non-fatal.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-0.25.0-fix-float-comparisons-in-tests.patch"

  cp "${FILESDIR}/waf-${WAF_PV}" "${BUILD_DIR}"/waf || die
  chmod +x "${BUILD_DIR}"/waf || die

  ./waf configure --keep \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --confdir="${EPREFIX%/}"/etc/${PN} \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --incdir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --htmldir="${EPREFIX%/}/usr/share/doc/${PN}-${PV}/html" \
    $(usex cli '' '--disable-cplayer') \
    $(use_enable 'libmpv' libmpv-shared) \
    --disable-libmpv-static \
    --disable-static-build \
    $(usex !optimize --disable-optimize) \
    --disable-debug-build \
    --disable-html-build \
    $(use_enable 'doc' pdf-build) \
    $(use_enable 'cplugins') \
    --disable-zsh-comp \
    --disable-test \
    --disable-android \
    $(use_enable 'iconv') \
    --disable-libsmbclient \
    $(usex lua "--lua=$(usex luajit luajit 51)" '--disable-lua') \
    $(use_enable 'javascript') \
    $(use_enable 'libass') \
    $(use_enable 'libass' libass-osd) \
    $(use_enable 'zlib') \
    $(use_enable 'encode' encoding) \
    --disable-libbluray \
    --disable-dvdread \
    --disable-dvdnav \
    --disable-cdda \
    $(use_enable 'uchardet') \
    --disable-rubberband \
    $(use_enable 'lcms' lcms2) \
    --disable-vapoursynth \
    --disable-vapoursynth-lazy \
    $(use_enable 'archive' libarchive) \
    --enable-libavdevice \
    $(use_enable 'sdl' sdl2) \
    --disable-sdl1 \
    --disable-oss-audio \
    --disable-rsound \
    --disable-sndio \
    --disable-pulse \
    --disable-jack \
    --disable-openal \
    --disable-opensles \
    $(use_enable 'alsa') \
    --disable-coreaudio \
    --disable-cocoa \
    $(use_enable 'drm') \
    $(use_enable 'gbm') \
    $(usex '0.28.2' --disable-wayland-scanner) \
    $(usex '0.28.2' --disable-wayland-protocols) \
    $(usex '0.28.2' --disable-wayland) \
    $(use_enable 'X' x11) \
    $(use_enable 'xv') \
    --disable-gl-cocoa \
    $(usex opengl "$(use_enable X gl-x11)" '--disable-gl-x11') \
    $(usex egl "$(use_enable X egl-x11)" '--disable-egl-x11') \
    $(usex egl "$(use_enable gbm egl-drm)" '--disable-egl-drm') \
    $(usex '0.28.2' --disable-gl-wayland) \
    $(use_enable 'vdpau') \
    $(usex vdpau "$(use_enable opengl vdpau-gl-x11)" '--disable-vdpau-gl-x11') \
    $(use_enable 'vaapi') \
    $(usex vaapi "$(use_enable X vaapi-x11)" '--disable-vaapi-x11') \
    $(usex '0.28.2' --disable-vaapi-wayland) \
    $(usex vaapi "$(use_enable gbm vaapi-drm)" '--disable-vaapi-drm') \
    $(use_enable 'libcaca' caca) \
    $(use_enable 'jpeg') \
    --disable-rpi \
    $(usex libmpv "$(use_enable opengl plain-gl)" '--disable-plain-gl') \
    --disable-mali-fbdev \
    $(usex opengl '' '--disable-gl') \
    --disable-cuda-hwaccel \
    $(use_enable 'v4l' tv) \
    $(use_enable 'v4l' tv-v4l2) \
    $(use_enable 'v4l' libv4l2) \
    $(use_enable 'v4l' audio-input) \
    --disable-dvbin \
    --disable-apple-remote \
    --disable-vaapi-glx \
    --disable-vaapi-x-egl \
    --disable-build-date \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  ./waf build || die "Failed make build"

  ./waf --destdir="${ED}" install || die "make install... error"

  if use 'lua'; then
    insinto /usr/share/${PN}
    doins -r TOOLS/lua
  fi
  if use 'tools'; then
    dobin TOOLS/mpv_identify.sh TOOLS/umpv
    newbin TOOLS/idet.sh mpv_idet.sh
  fi

  cd "${ED}/" || die "install dir: not found... error"

  strip --verbose --strip-all "bin/${PN}" "$(get_libdir)/"lib${PN}.so.1.*

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
