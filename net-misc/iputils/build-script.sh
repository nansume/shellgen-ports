#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-21 19:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="Network monitoring tools including ping and ping6"
HOMEPAGE="https://wiki.linuxfoundation.org/networking/iputils"
LICENSE="BSD | GPL-2+"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="20240117"
SRC_URI="https://github.com/iputils/${PN}/releases/download/${PV}/${PN}-${PV}.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+arping -caps -clockdiff -doc -idn -nls -test +tracepath +static (+musl) +stest +strip"
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
  "dev-build/meson6  # build tool" \
  "dev-build/samurai  # alternative for ninja" \
  "dev-lang/python3  # for meson" \
  "dev-libs/expat  # python bundled" \
  "dev-libs/libxml2  # deps libxslt" \
  "dev-libs/libxslt" \
  "dev-python/importlib-resources  # for meson (build tool)" \
  "dev-python/mako" \
  "dev-python/py3-setuptools  # for meson (build tool)" \
  "dev-python/zipp  # for meson (build tool)" \
  "dev-util/cmake  # it optional?" \
  "dev-util/pkgconf" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/m4  # required for ninja" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib  # for zipp[meson],glib" \
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
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-flags -Os
  append-ldflags -Wl,--gc-sections
  append-cflags -ffunction-sections -fdata-sections
  append-ldflags "-s -static --static"
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc -static --static"

  mkdir -m 0755 -- "${BUILD_DIR}/build/"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  meson setup \
    --prefix "${EPREFIX%/}/" \
    --bindir "bin" \
    --datadir "usr/share" \
    --wrap-mode "nodownload" \
    --buildtype "release" \
    $(usex 'strip' --strip) \
    -DUSE_CAP=$(usex 'caps' true false) \
    -DUSE_IDN=$(usex 'idn' true false) \
    -DBUILD_ARPING=$(usex 'arping' true false) \
    -DBUILD_CLOCKDIFF=$(usex 'clockdiff' true false) \
    -DBUILD_PING="true" \
    -DBUILD_TRACEPATH=$(usex 'tracepath' true false) \
    -DNO_SETCAP_OR_SUID="true" \
    -Dsystemdunitdir="false" \
    -DUSE_GETTEXT=$(usex 'nls' true false) \
    -DSKIP_TESTS="false" \
    -DBUILD_HTML_MANS=$(usex 'doc' true false) \
    -DBUILD_MANS="true" \
    "${BUILD_DIR}/build" \
    || die "meson setup... error"

  ninja -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${INSTALL_DIR}" meson install --no-rebuild -C "${BUILD_DIR}/build" || die "meson install... error"

  cd "${ED}/" || die "install dir: not found... error"

  LD_LIBRARY_PATH=
  use 'stest' && { bin/ping -V || die "binary work... error";}
  ldd "bin/ping" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
