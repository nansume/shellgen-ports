#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-27 10:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs -nopie +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Media player and framework with support for most multimedia files and streaming"
HOMEPAGE="https://www.videolan.org/vlc/"
LICENSE="LGPL-2.1 GPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]*}
PV="3.0.19"  # no-build
PV="3.0.17.4"
SRC_URI="
  http://download.videolan.org/vlc/${PV}/vlc-${PV}.tar.xz
  #https://www.linuxfromscratch.org/patches/blfs/12.1/vlc-3.0.20-taglib-1.patch
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
IUSE="-static -static-libs +shared -doc -nopie (+musl) +stest +strip"
IUSE="${IUSE} -a52 +alsa -aom +archive -aribsub -bidi -bluray -cddb -chromaprint -chromecast -dav1d -dbus"
IUSE="${IUSE} -dc1394 -debug -directx -dts -dvbpsi -dvd -encode -faad -fdk +ffmpeg -flac -fluidsynth"
IUSE="${IUSE} -fontconfig -gcrypt -gme -keyring -gstreamer +gui -ieee1394 -jack -jpeg -kate"
IUSE="${IUSE} +libass -libcaca -libnotify +libsamplerate -libtar -libtiger -linsys -lirc -live -lua"
IUSE="${IUSE} -macosx-notifications -mad -matroska -modplug -mp3 -mpeg -mtp -musepack -ncurses -nfs +ogg"
IUSE="${IUSE} -omxil +optimisememory -opus -png -projectm -pulseaudio -rdp -run-as-root -samba -sdl-image"
IUSE="${IUSE} +sftp -shout -sid +skins -soxr -speex -srt +ssl -svg -taglib -theora -tremor -truetype -twolame"
IUSE="${IUSE} -udev -upnp -vaapi -v4l -vdpau -vnc +vpx -wayland +X -x264 -x265 +xml -zeroconf -zvbi"
IUSE="${IUSE} -cpu_flags_arm_neon -cpu_flags_ppc_altivec +cpu_flags_x86_mmx +cpu_flags_x86_sse"
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
  "app-arch/libarchive" \
  "app-arch/tar  # required for: skins?" \
  "app-shells/bash  # for doltcompile (no-posix)" \
  "dev-lang/perl  # required for autotools" \
  "dev-lang/yasm" \
  "dev-libs/expat  # deps opengl,libass" \
  "#dev-libs/glib  # gtk2?" \
  "dev-libs/glib-compat  # deps libass" \
  "dev-libs/gmp  # for gnutls" \
  "dev-libs/fribidi  # deps libass" \
  "dev-libs/icu-compat # deps qt5base (Qt5Core)" \
  "#dev-libs/libffi  # for glib" \
  "dev-libs/libxml2  # xml?" \
  "dev-libs/libtasn1  # for gnutls" \
  "dev-libs/libunistring  # for gnutls" \
  "dev-libs/nettle  # for gnutls" \
  "#dev-libs/pcre  # optional (internal pcre glib-2.68.4) gtk2?" \
  "dev-libs/openssl3  # deps libarchive" \
  "dev-qt/qt5base  # for gui-qt" \
  "dev-qt/qt5svg  # for gui-qt" \
  "dev-qt/qt5x11extras  # for gui-qt" \
  "dev-util/byacc  # alternative a bison" \
  "dev-util/pkgconf" \
  "media-gfx/imagemagick  # imagemagick?" \
  "#media-libs/a52dec  # a52?" \
  "#media-libs/aalib  # aalib?" \
  "media-libs/alsa-lib  # alsa?" \
  "media-libs/libass" \
  "#media-libs/glu  # opengl?" \
  "#media-libs/faad2  # aac?" \
  "media-libs/flac  # flac?" \
  "media-libs/fontconfig  # deps libass" \
  "media-libs/freetype  # skins?,deps libass" \
  "#media-libs/libcaca  # libcaca?" \
  "media-libs/libjpeg-turbo  # jpeg?" \
  "media-libs/harfbuzz  # deps libass" \
  "media-libs/libogg  # speex? theora? vorbis?" \
  "media-libs/libsamplerate" \
  "#media-libs/libmad  # mad?" \
  "#media-libs/libmng  # mng?" \
  "#media-libs/libmodplug  # modplug?" \
  "#media-libs/libv4l  # v4l?" \
  "#media-libs/libva  # vaapi?" \
  "media-libs/libvorbis  # vorbis?" \
  "media-libs/libvpx  # vpx?" \
  "#media-libs/libtheora  # theora?" \
  "#media-libs/mesa  # opengl?" \
  "media-libs/sdl  # sdl?" \
  "#media-sound/musepack-tools  # musepack?" \
  "#media-sound/wavpack  # wavpack?" \
  "media-video/ffmpeg" \
  "#net-fs/libnfs  # nfs?" \
  "net-libs/gnutls" \
  "net-libs/libssh2  # sftp?" \
  "net-libs/mbedtls  # deps libssh2" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "#sys-devel/gettext  # for nls (optional)" \
  "sys-devel/lex  # alternative a flex" \
  "#sys-devel/libtool  # (dev-build/libtool) optional" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl  # required ?" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  "x11-base/xorg-proto  # for x11" \
  "#x11-libs/gdk-pixbuf  # gtk2?" \
  "#x11-libs/libdrm  # opengl?" \
  "x11-libs/libice  # deps qt5" \
  "#x11-libs/libpciaccess  # opengl?" \
  "#x11-libs/libvdpau  # vdpau? opengl?" \
  "x11-libs/libsm  # deps qt5" \
  "x11-libs/libx11  # for x11" \
  "x11-libs/libxau  # for x11" \
  "x11-libs/libxcb  # for x11" \
  "x11-libs/xcb-util  # for x11" \
  "x11-libs/xcb-util-keysyms  # for x11" \
  "x11-libs/libxcursor  # deps qt5" \
  "#x11-libs/libxdamage  # opengl?" \
  "x11-libs/libxdmcp  # for x11" \
  "x11-libs/libxext  # required for x11,skins" \
  "x11-libs/libxfixes" \
  "x11-libs/libxi  # deps qt5" \
  "x11-libs/libxinerama  # xinerama? skins?" \
  "x11-libs/libxpm  # skins?" \
  "x11-libs/libxrandr" \
  "x11-libs/libxrender  # for libxft" \
  "#x11-libs/libxshmfence  # opengl?" \
  "x11-libs/libxt  # X?" \
  "x11-libs/libxv  # xv?" \
  "#x11-libs/libxvmc  # xvmc?" \
  "#x11-libs/libxxf86vm  # opengl?" \
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
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector $(usex 'nopie' -no-pie) -g0 -march=$(arch | sed 's/_/-/')

  CC="cc$(usex static ' --static')"
  CXX="c++$(usex static ' --static')"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  #patch -p1 -E < "${FILESDIR}/"vlc-3.0.20-taglib-1.patch

  # Don't use --started-from-file when not using dbus.
  if ! use 'dbus'; then
    sed 's/ --started-from-file//' -i share/vlc.desktop.in || : die
  fi

  ./configure \
    BUILDCC="${CC}" \
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
    --enable-optimizations \
    --disable-lua \
    --disable-libplacebo \
    --disable-aa \
    --disable-mad \
    --disable-a52 \
    --disable-vcd \
    --disable-screen \
    --disable-libgcrypt \
    --enable-fast-install \
    --disable-update-check \
    --enable-vlc \
    --enable-vorbis \
    --enable-alsa \
    --disable-aom \
    $(use_enable 'archive') \
    $(use_enable 'aribsub') \
    $(use_enable 'bidi' fribidi) \
    $(use_enable 'bidi' harfbuzz) \
    --disable-bluray \
    $(use_enable 'cddb' libcddb) \
    --disable-chromaprint \
    --disable-chromecast \
    --disable-microdns \
    --disable-neon \
    --disable-altivec \
    $(use_enable 'cpu_flags_x86_mmx' mmx) \
    $(use_enable 'cpu_flags_x86_sse' sse) \
    --disable-dav1d \
    --disable-dbus \
    --disable-kwallet \
    --disable-dc1394 \
    --disable-debug \
    --disable-directx \
    --disable-d3d11va \
    --disable-dxva2 \
    $(use_enable 'dts' dca) \
    --disable-dvbpsi \
    --disable-dvdnav \
    --disable-dvdread \
    $(use_enable 'encode' sout) \
    $(use_enable 'encode' vlm) \
    $(use_enable 'faad') \
    $(use_enable 'fdk' fdkaac) \
    $(use_enable 'ffmpeg' avcodec) \
    $(use_enable 'ffmpeg' avformat) \
    --disable-postproc \
    $(use_enable 'ffmpeg' swscale) \
    $(use_enable 'flac') \
    --disable-fluidsynth \
    --disable-fontconfig \
    --enable-freetype \
    --with-default-font="/usr/share/fonts/dejavu/DejaVuSans.ttf" \
    --with-default-font-family="Sans" \
    --with-default-monospace-font="/usr/share/fonts/dejavu/DejaVuSansMono.ttf" \
    --with-default-monospace-font-family="Monospace" \
    --disable-gme \
    $(use_enable 'keyring' secret) \
    --disable-gst-decode \
    $(use_enable 'gui' qt) \
    --disable-dv1394 \
    --disable-jack \
    $(use_enable 'jpeg') \
    --disable-kate \
    $(use_enable 'libass') \
    --disable-caca \
    --disable-notify \
    $(use_enable 'libsamplerate' samplerate) \
    $(use_enable 'libtar') \
    $(use_enable 'libtiger' tiger) \
    $(use_enable 'linsys') \
    --disable-lirc \
    $(use_enable 'live' live555) \
    --disable-osx-notifications \
    $(use_enable 'matroska') \
    --disable-mod \
    $(use_enable 'mp3' mpg123) \
    $(use_enable 'mpeg' libmpeg2) \
    $(use_enable 'mtp') \
    $(use_enable 'musepack' mpc) \
    $(use_enable 'ncurses') \
    --disable-nfs \
    $(use_enable 'ogg') \
    --disable-omxil \
    --disable-omxil-vout \
    $(use_enable 'optimisememory' optimize-memory) \
    $(use_enable 'opus') \
    $(use_enable 'png') \
    $(use_enable 'projectm') \
    --disable-pulse \
    --disable-freerdp \
    --disable-run-as-root \
    --disable-smbclient \
    $(use_enable 'sdl-image') \
    $(use_enable 'sftp') \
    $(use_enable 'shout') \
    $(use_enable 'sid') \
    --enable-skins2 \
    $(use_enable 'soxr') \
    $(use_enable 'speex') \
    $(use_enable 'srt') \
    $(use_enable 'ssl' gnutls) \
    $(use_enable 'svg') \
    $(use_enable 'svg' svgdec) \
    $(use_enable 'taglib') \
    $(use_enable 'theora') \
    $(use_enable 'tremor') \
    $(use_enable 'twolame') \
    --disable-udev \
    --disable-upnp \
    --disable-v4l2 \
    --disable-libva \
    --disable-vdpau \
    --disable-vnc \
    $(use_enable 'vpx') \
    --disable-wayland \
    $(use_with 'X' x) \
    $(use_enable 'X' xcb) \
    $(use_enable 'X' xvideo) \
    $(use_enable 'x264') \
    $(use_enable 'x264' x26410b) \
    $(use_enable 'x265') \
    $(use_enable 'xml' libxml2) \
    --disable-avahi \
    --disable-zvbi \
    --disable-telx \
    --with-kde-solid="${EPREFIX}"/usr/share/solid/actions \
    --disable-asdcp \
    --disable-coverage \
    --disable-cprof \
    --disable-crystalhd \
    --disable-decklink \
    --disable-gles2 \
    --disable-goom \
    --disable-kai \
    --disable-kva \
    --disable-maintainer-mode \
    --disable-merge-ffmpeg \
    --disable-mfx \
    --disable-mmal \
    --disable-opencv \
    --disable-opensles \
    --disable-oss \
    --disable-rpi-omxil \
    --disable-schroedinger \
    --disable-shine \
    --disable-sndio \
    --disable-spatialaudio \
    --disable-vsxu \
    --disable-wasapi \
    --disable-wma-fixed \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    --disable-nls \
    --disable-rpath \
    || die "configure... error"

  # fixbug (nocompat busybox <tar>):  tar: unrecognized option: format=ustar
  sed -e "/ skins2/ s@^\([[:space:]]\)tar[[:space:]]@\1/bin/tar @" -i share/Makefile

  make -j "$(nproc)" || die "Failed make build"

  cp -n share/vlc.appdata.xml.in share/vlc.appdata.xml

  make DESTDIR="${ED}" docdir="/usr/share/doc/${PN}-${PV}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  find "$(get_libdir)/" -name '*.la' -delete || die

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
