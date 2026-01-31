#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Description: OpenWrt debug service
# Homepage: https://git.openwrt.org/project/udebug.git
# License: GPL-2.0
# Depends: libubox json-c ubus ucode
# Date: 2026-01-22 19:00 UTC - last change
# Build with useflag: +static +static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# https://github.com/openwrt/openwrt/archive/master.tar.gz  package/libs/udebug/Makefile

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="20260122"
PV="2026.01.16"
HASH="875e1a7af6ca9d86524d18169c3a79f4a1920053"  # 2026.01.16
SRC_URI="https://github.com/openwrt/${PN}/archive/master.tar.gz -> ${PN}-${PV}.tar.gz"
SRC_URI="https://github.com/openwrt/${PN}/archive/${HASH}.tar.gz -> ${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
inst="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static +static-libs +shared -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${HASH}"
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
PROG="udebugd"

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

# required: ucode

pkginst \
  "dev-build/cmake3" \
  "dev-lang/ucode" \
  "dev-libs/json-c  # required" \
  "dev-libs/libubox" \
  "dev-util/pkgconf" \
  "sys-apps/ubus" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
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
  append-flags -Os
  append-ldflags -Wl,--gc-sections
  append-ldflags "-s -static --static"
  append-cflags -ffunction-sections -fdata-sections
  append-flags -DNDEBUG -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc"

  use 'strip' && inst="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  for F in "${PDIR%/}/patches/"*".diff"; do
    case ${F} in *'*'*) continue;; esac
    [ -f "${F}" ] && patch -p1 -E < "${F}"
  done

  ubox="/$(get_libdir)/libubox.so"  # libubox
  ubus="/$(get_libdir)/libubus.so"
  sed \
    -e "s| -lubox -lubus)$| /$(get_libdir)/libubox.a /$(get_libdir)/libubus.a)|" \
    -e "s|(udebug \${ubox} \${ubus})$|(udebug ${ubox} ${ubus})|" \
    -e "s|(ucode_lib \${ubox} udebug)$|(ucode_lib ${ubox} udebug)|" \
    -i CMakeLists.txt

  cmake -B build -G "Unix Makefiles" \
    -D CMAKE_INSTALL_PREFIX="/usr" \
    -D CMAKE_BUILD_TYPE="None" \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -W no-dev \
    || die "Failed cmake build"

  sed -e 's|.so$|.a|' -i build/CMakeCache.txt

  DESTDIR="${ED}" cmake --build build --target ${inst} -j "$(nproc)" || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  mkdir -m 0755 -- etc/ etc/init.d/ etc/config/

  cp -v "${PDIR%/}"/files/udebug.config "${ED}"/etc/config/udebug
  cp -v "${PDIR%/}"/files/udebug.init "${ED}"/etc/init.d/udebug

  mv -v -n "usr/sbin" .
  mv -v -n "usr/lib" "$(get_libdir)"

  use 'stest' && { sbin/${PROG} -h || : die "binary work... error";}
  ldd "sbin/${PROG}" || { use 'static' && true || : die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz