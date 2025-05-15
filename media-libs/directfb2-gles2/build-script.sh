#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-04-22 19:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs -nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=directfb2-gles2-git

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="OpenGL ES 2.0 GFX driver for DirectFB2"
HOMEPAGE="https://directfb2.github.io/"
LICENSE="LGPL"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN="DirectFB2-gles2"
PV="2.0.0p20250422"
SRC_URI="https://github.com/directfb2/${PN}/archive/master.tar.gz -> ${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+flux +python -static-libs +shared -nopie -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-master"
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
  "dev-build/meson7  # build tool" \
  "#dev-build/muon  # alternative for meson - build ok, no is some warnings" \
  "dev-build/samurai  # alternative for ninja" \
  "dev-lang/python38  # deps meson" \
  "dev-libs/directfb2" \
  "dev-libs/expat  # deps meson" \
  "dev-libs/libffi  # deps meson" \
  "dev-util/pkgconf" \
  "media-libs/mesa" \
  "sys-devel/binutils" \
  "sys-devel/fluxcomp" \
  "sys-devel/gcc9" \
  "sys-devel/m4  # required for ninja" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl0" \
  "sys-libs/zlib  # deps meson" \
  "x11-libs/libdrm" \
  "x11-libs/libpciaccess" \
  "x11-libs/libvdpau" \
  "x11-libs/libx11  # for x11" \
  "x11-libs/libxau  # for x11" \
  "x11-libs/libxcb  # for x11" \
  "x11-libs/libxdamage" \
  "x11-libs/libxdmcp  # for x11" \
  "x11-libs/libxext  # optional" \
  "x11-libs/libxfixes" \
  "x11-libs/libxrandr" \
  "x11-libs/libxrender  # for libxft" \
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

  meson setup \
    --default-library=$(usex 'shared' shared static) \
    -Dprefix="/" \
    -Dlibdir="$(get_libdir)" \
    -Dincludedir="usr/include" \
    -Ddatadir="usr/share" \
    -Dwrap_mode="nodownload" \
    -Dbuildtype="release" \
    -Dstrip=$(usex 'strip' true false) \
    "${BUILD_DIR}/build" "${BUILD_DIR}" \
    || die "meson setup... error"

  ninja -j "$(nproc)" -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${INSTALL_DIR}" meson install --no-rebuild -C "${BUILD_DIR}/build" || die "meson install... error"

  cd "${ED}/" || die "install dir: not found... error"

  grep '${prefix}' < $(get_libdir)/pkgconfig/directfb-gfxdriver-gles2.pc
  sed -e 's|${prefix}||' -i $(get_libdir)/pkgconfig/directfb-gfxdriver-gles2.pc || die

  ldd "$(get_libdir)"/directfb-2.0-0/gfxdrivers/libdirectfb_gles2.so || die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz