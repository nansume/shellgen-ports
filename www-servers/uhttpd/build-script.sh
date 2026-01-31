#!/bin/sh
# Copyright (C) 2024-2026 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Description: OpenWRT HTTP server
# Homepage: https://git.openwrt.org/project/uhttpd.git
# License: ISC
# Depends: json-c lua51 libubus libucode ustream-ssl
# Date: 2024-11-08 16:00 UTC, 2026-01-25 22:00 UTC - last change
# Build with useflag: +static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# https://github.com/openwrt/openwrt/archive/master.tar.gz  network/services/uhttpd/Makefile
# https://deepwiki.com/openwrt/uhttpd/1.2-build-system

# BUG: libc static-link ignore
# BUG: libubus static-link failed

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
PV="2023.06.25"
PV="2025.10.03"
HASH="34a8a74dbdec3c0de38abc1b08f6a73c51263792"  # 2023.06.25
HASH="ebb92e6b339b88bbc6b76501b6603c52d4887ba1"  # 2025.10.03
SRC_URI="https://git.openwrt.org/?p=project/${PN}.git"  # get-403-forbidden
SRC_URI="${SRC_URI};a=snapshot;h=${HASH};sf=tgz -> ${PN}-${PV}.tar.gz"  # get-403-forbidden
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
IUSE="-ssl +lua +ubus +ucode +static -shared -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${HASH%${HASH#???????}}"  # get-403-forbidden
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
  "dev-lang/lua51  # optional" \
  "dev-lang/ucode  # optional" \
  "dev-libs/json-c" \
  "dev-libs/libubox" \
  "dev-util/cmake" \
  "dev-util/pkgconf" \
  "net-libs/ustream-ssl  # it missing" \
  "sys-apps/ubus  # optional (BUG: static-link failed)" \
  "sys-devel/binutils9" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
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
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-flags -Os -DNDEBUG
  append-ldflags -Wl,--gc-sections
  append-ldflags "-s -static --static"
  append-cflags -ffunction-sections -fdata-sections
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc"

  use 'strip' && inst="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  ubox="/$(get_libdir)/libubox.so"  # libubox
  ubus="/$(get_libdir)/libubus.so"
  json="/$(get_libdir)/libjson-c.so"
  blobmsg_json="/$(get_libdir)/libblobmsg_json.so"

  sed \
    -e 's/-Werror //' \
    -e '/_LIBRARIES(uhttpd / s| ${ubox} dl .*| ${json_script} ${blobmsg_json} ${libjson} ${LIBS} ${ubox})|' \
    -e "s|(uhttpd_ubus \${ubus} \${ubox} \${blobmsg_json} \${libjson})$|(uhttpd_ubus ${ubus} ${ubox} ${blobmsg_json} ${json})|" \
    -i CMakeLists.txt

  . runverb \
  cmake -B build -G "Unix Makefiles" \
    -D CMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -D CMAKE_BUILD_TYPE="None" \
    -D TLS_SUPPORT=$(usex 'ssl' ON OFF) \
    -D LUA_SUPPORT=$(usex 'lua' ON OFF) \
    -D UBUS_SUPPORT=$(usex 'ubus' ON OFF) \
    -D UCODE_SUPPORT=$(usex 'ucode' ON OFF) \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -W no-dev \
    || die "Failed cmake build"

  sed -e 's|.so$|.a|' -i build/CMakeCache.txt

  DESTDIR="${ED}" cmake --build build --target ${inst} -j "$(nproc)" || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  mkdir -m 0755 -- etc/ etc/init.d/ etc/config/ etc/uci-defaults/

  cp -v "${PDIR%/}"/files/uhttpd.init "${ED}"/etc/init.d/uhttpd
  cp -v "${PDIR%/}"/files/uhttpd.config "${ED}"/etc/config/uhttpd
  cp -v "${PDIR%/}"/files/ubus.default "${ED}"/etc/uci-defaults/00_uhttpd_ubus
  chmod +x "${ED}"/etc/uci-defaults/00_uhttpd_ubus

  mv -v -n "lib" "$(get_libdir)"

  use 'stest' && { bin/${PN} - || : die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz