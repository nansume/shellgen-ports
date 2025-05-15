#!/bin/sh
# Copyright (C) 2024-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2024-04-16 20:00 UTC - last change
# Date: 2025-02-08 19:00 UTC - last change
# Build with useflag: -static -lfs +nopie +python2 +patch -doc -xstub +musl +stest +strip +x32
# Build with useflag: +static -lfs +nopie +python2 -alsa -aio -sdl +patch -doc -xstub +musl +stest +strip +x32

# https://git.alpinelinux.org/aports/plain/community/qemu/APKBUILD

#inherit build pkg-export python-r1 build-functions  # BUG: inherit: not found

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH PYTHON _S

DESCRIPTION="QEMU + Kernel-based Virtual Machine userland tools"
HOMEPAGE="http://www.qemu.org http://www.linux-kvm.org"
LICENSE="GPL-2 LGPL-2 BSD-2"
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
PV="1.7.2"
PV="2.0.2"
#PV="4.0.0"  # 4.0.0-r666 - support x32
HASH="d62c42e26a2c30ae027bec66bf42fbfa9a7e69ae"
BASEURI="https://cgit.gentoo.org/proj/hardened-dev.git/plain/app-emulation/qemu"
SRC_URI="
  https://download.qemu.org/${PN}-${PV}.tar.xz
  http://shellgen.mooo.com/pub/distfiles/patch/${PN}/${PN}-1.7.0-cflags.patch
  ${BASEURI}/files/qemu-1.5.3-openpty.patch?h=musl&id=${HASH} -> qemu-1.5.3-openpty.patch
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
IUSE="+static -static-softmmu -static-user (+musl) -doc +ncurses -xstub -debug +stest -test +strip"
IUSE="${IUSE} -pin-upstream-blobs +python2 (-python3) -python +sdl -sdl2 +pixman -guest +softmmu"
IUSE="${IUSE} -accessibility +aio -bluetooth +caps -filecaps +curl +fdt -glusterfs -rbd -sasl -gtk"
IUSE="${IUSE} -infiniband -iscsi +jpeg -png -bzip2 -lzo -nfs -nls -opengl -alsa -pulseaudio"
IUSE="${IUSE} -snappy -spice -ssh -selinux +seccomp -smartcard -systemtap -tci +threads -tls"
IUSE="${IUSE} -usb -usbredir +uuid -vde +vhost-net -vhost-scsi -virtfs +vnc -xattr -xen -xfs"
IUSE="${IUSE} -caps -curl -fdt -jpeg -vnc -seccomp -uuid +blobs"
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
PATCH="patch"
#PYTHON=true

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

use 'python' || {
  if use 'python2' || use 'python3'; then
    IUSE="${IUSE} +python"
  fi
}

use 'static' && {
static-build \
  "sys-libs/musl" \
  "dev-libs/libbsd" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/glib57" \
  || die "Failed static build pkg bundled... error"
}

pkginst \
  "#app-busybox/fold" \
  "#dev-libs/expat  # python3 bundled" \
  "dev-libs/glib74" \
  "dev-libs/libffi  # for glib" \
  "#dev-libs/pcre  # optional (internal pcre glib-2.68.4)" \
  "dev-libs/pcre2  # for glib74" \
  "dev-util/pkgconf" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/libtool" \
  "sys-devel/make" \
  "sys-devel/patch  # optional" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  || die "Failed install build pkg depend... error"

pkginst \
  "#dev-libs/directfb  # optional" \
  "sys-firmware/seabios  # optional" \
  "sys-firmware/ipxe  # optional" \
  "dev-libs/libbsd" \
  "dev-libs/libusb  # optional" \
  "media-libs/sdl  # optional" \
  "media-libs/alsa-lib  # sdl" \
  "media-libs/libjpeg-turbo1  # sdl" \
  || die "Failed install build pkg depend... error"

pkginst \
  "dev-lang/perl  # required for autotools" \
  "sys-devel/autoconf  # required for autotools" \
  "sys-devel/automake  # required for autotools" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/gettext  # optional" \
  || die "Failed install build pkg depend... error"

use 'aio'      && pkginst "dev-libs/libaio"
use 'ncurses'  && pkginst "sys-libs/ncurses"
use 'python2'  && pkginst "dev-lang/python2"
#use 'python3'  && pkginst "dev-lang/python38"

use 'pixman'  && {
pkginst \
  "media-libs/libpng" \
  "x11-libs/pixman" \
  "#x11-misc/util-macros" \
  "#x11-base/xcb-proto" \
  "x11-base/xorg-proto" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxcb" \
  "x11-libs/libxext" \
  "x11-libs/xtrans"
}

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  # python required for code generator otherwise build failed
  use 'python' && . "${PDIR%/}/etools.d/"epython || PYTHON="true"

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  { test -x "/bin/g${PATCH}" && test ! -L "/bin/g${PATCH}" ;} && PATCH="/bin/g${PATCH}"
  printf %s\\n "PATCH='${PATCH}'"

  audio_opts=
  use 'alsa' && audio_opts="alsa"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  # Alter target makefiles to accept CFLAGS set via flag-o
  sed -i -r \
    -e 's/^(C|OP_C|HELPER_C)FLAGS=/\1FLAGS+=/' \
    Makefile Makefile.target || die

  # Cheap hack to disable gettext .mo generation.
  use 'nls' || rm -- po/*.po

  ${PATCH} -p1 -E < "${FILESDIR}/${PN}-1.7.0-cflags.patch"
  case $(tc-chost) in
    *-"musl"*)
      patch -p1 -E < "${FILESDIR}/${PN}-1.5.3-openpty.patch"
    ;;
  esac

  . runverb \
  ./configure \
    --cc="gcc" \
    --cxx="g++" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}/etc" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --docdir="${DPREFIX}/share/doc" \
    $(use_enable 'accessibility' brlapi) \
    --disable-pie \
    --disable-stack-protector \
    $(use_enable 'ncurses' curses) \
    $(use_with 'pixman' system-pixman) \
    $(usex !pixman '--without-pixman') \
    --python=${PYTHON} \
    $(usex !blobs --disable-blobs) \
    --disable-tools \
    $(use_enable 'softmmu' system) \
    --disable-attr \
    --audio-drv-list="${audio_opts}" \
    $(use_enable 'aio' linux-aio) \
    --disable-coroutine-pool \
    --disable-docs \
    $(use_enable 'fdt') \
    $(use_enable 'bluetooth' bluez) \
    $(use_enable 'caps' cap-ng) \
    $(use_enable 'curl') \
    $(use_enable 'glusterfs') \
    $(use_enable 'gtk') \
    $(use_enable 'infiniband' rdma) \
    $(use_enable 'iscsi' libiscsi) \
    $(use_enable 'jpeg' vnc-jpeg) \
    $(usex 'lzo' --enable-lzo) \
    $(use_enable 'nfs' libnfs) \
    $(use_enable 'opengl' glx) \
    $(use_enable 'png' vnc-png) \
    $(use_enable 'rbd') \
    $(use_enable 'sasl' vnc-sasl) \
    $(use_enable 'sdl') \
    $(use_enable 'seccomp') \
    $(use_enable 'smartcard' smartcard-nss) \
    $(usex 'snappy' --enable-snappy) \
    $(use_enable 'spice') \
    $(use_enable 'ssh' libssh2) \
    $(use_enable 'tls' quorum) \
    $(use_enable 'tls' vnc-tls) \
    $(use_enable 'tls' vnc-ws) \
    $(use_enable 'usb' libusb) \
    $(use_enable 'usbredir' usb-redir) \
    $(use_enable 'uuid') \
    $(use_enable 'vde') \
    $(use_enable 'virtfs') \
    $(use_enable 'xen') \
    $(use_enable 'xen' xen-pci-passthrough) \
    $(use_enable 'xfs' xfsctl) \
    --disable-guest-agent \
    $(use_enable 'guest' guest-base) \
    --disable-guest-agent \
    --disable-kvm \
    --disable-qom-cast-debug \
    --disable-user \
    --disable-bsd-user \
    --disable-linux-user \
    --disable-vhost-net \
    $(use_enable 'vhost-scsi') \
    --disable-vnc \
    $(use_enable 'tci' tcg-interpreter) \
    --target-list="$(arch)-softmmu" \
    $(use_enable 'debug' debug-info) \
    $(use_enable 'debug' debug-tcg) \
    --disable-werror \
    $(usex 'static' --static) \
    $(usex !strip --disable-strip) \
    || die "configure... error"

  make -j "$(nproc --ignore=1)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" install || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'static' && LD_LIBRARY_PATH=
  use 'stest' && { bin/${PN}-system-$(arch) --version || true "binary work... error";}

  ldd "bin/${PN}-system-$(arch)" || { use 'static' && true;}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
