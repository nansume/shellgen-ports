#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-05-25 16:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs -nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/media-libs/libpulse/libpulse-17.0.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Libraries for PulseAudio clients"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/PulseAudio/"
LICENSE="LGPL-2.1+"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN="pulseaudio"
PV="17.0"
SRC_URI="
  https://freedesktop.org/software/pulseaudio/releases/${PN}-${PV}.tar.xz
  http://data.gpo.zugaina.org/gentoo/media-libs/libpulse/files/pulseaudio-17.0-backport-pr807.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-asyncns -dbus -doc -glib -gtk -selinux -systemd -test -valgrind -X"
IUSE="${IUSE} (-static-libs) +shared -nopie (+musl) +stest +strip"
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
PROG="pactl"

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
  "dev-build/meson7  # build tool" \
  "#dev-build/muon  # alternative for meson" \
  "dev-build/samurai  # alternative for ninja" \
  "dev-db/sqlite3  # deps libsndfile" \
  "dev-lang/python3-8  # deps meson" \
  "dev-libs/expat  # deps meson,python" \
  "dev-libs/libffi  # deps meson" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib  # deps libsndfile" \
  "media-libs/flac  # deps libsndfile" \
  "media-libs/libogg  # deps libsndfile" \
  "media-libs/libvorbis  # deps libsndfile" \
  "media-libs/opus  # deps libsndfile" \
  "media-sound/lame  # deps libsndfile" \
  "media-sound/mpg123  # deps libsndfile" \
  "media-libs/libsndfile" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/m4  # required for ninja" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps meson" \
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
  append-flags -O2 -fno-stack-protector -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"
  patch -p1 -E < "${FILESDIR}"/pulseaudio-17.0-backport-pr807.patch

  # disable autospawn by client
  sed -e 's:; autospawn = yes:autospawn = no:g' -i src/pulse/client.conf.in || die

  meson setup \
    --default-library=$(usex 'shared' both static) \
    -D prefix="/" \
    -D bindir="bin" \
    -D libdir="$(get_libdir)" \
    -D includedir="usr/include" \
    -D datadir="usr/share" \
    -D localstatedir="${EPREFIX%/}"/var \
    -D wrap_mode="nodownload" \
    -D buildtype="release" \
    -D daemon=false \
    -D client=true \
    -D doxygen=$(usex 'doc' true false) \
    -D gcov=false \
    -D database=simple \
    -D stream-restore-clear-old-devices=true \
    -D running-from-build-tree=false \
    -D modlibexecdir="${EPREFIX%/}/usr/$(get_libdir)/pulseaudio/modules" \
    -D systemduserunitdir=/lib/systemd/unit.d \
    -D udevrulesdir="${EPREFIX%/}/lib/udev/rules.d" \
    -D bashcompletiondir="/usr/share/bash-completion" \
    -D alsa=enabled \
    -D asyncns=$(usex 'asyncns' enabled disabled) \
    -D avahi=disabled \
    -D bluez5=disabled \
    -D bluez5-gstreamer=disabled \
    -D bluez5-native-headset=false \
    -D bluez5-ofono-headset=false \
    -D dbus=$(usex 'dbus' enabled disabled) \
    -D elogind=disabled \
    -D fftw=disabled \
    -D glib=$(usex 'glib' enabled disabled) \
    -D gsettings=disabled \
    -D gstreamer=disabled \
    -D gtk=$(usex 'gtk' enabled disabled) \
    -D hal-compat=false \
    -D ipv6=true \
    -D jack=disabled \
    -D lirc=disabled \
    -D openssl=disabled \
    -D orc=disabled \
    -D oss-output=disabled \
    -D samplerate=disabled \
    -D soxr=disabled \
    -D speex=disabled \
    -D systemd=disabled \
    -D tcpwrap=disabled \
    -D udev=disabled \
    -D valgrind=disabled \
    -D x11=$(usex 'X' enabled disabled) \
    -D adrian-aec=false \
    -D webrtc-aec=disabled \
    -D man=$(usex 'doc' true false) \
    -D tests=$(usex 'test' true false) \
    -D strip=$(usex 'strip' true false) \
    "${BUILD_DIR}/build" "${BUILD_DIR}" \
    || die "meson setup... error"

  ninja -j "$(nproc)" -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${ED}" meson install --no-rebuild -C "${BUILD_DIR}/build" || die "meson install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || { find "$(get_libdir)/" \( -name '*.a' -o -name '*.la' \) -delete || die ;}

  #grep '${prefix}' < $(get_libdir)/pkgconfig/${XPN}.pc
  #sed -e 's|${prefix}||' -i $(get_libdir)/pkgconfig/${XPN}*.pc || : die

  rm -r -- "usr/share/bash-completion/" "usr/share/zsh/"

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)/${PN}"
  use 'stest' && { bin/${PROG} --version || : die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || : die "library deps work... error";}
  ldd "$(get_libdir)"/${XPN}.so || : die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz