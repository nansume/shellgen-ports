#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Description: Tiny scripting and templating language
# Homepage: https://github.com/jow-/ucode/
# License: ISC
# Depends: libjson-c libubox libnl-tiny libubus libuci zlib
# Date: 2026-01-22 19:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# https://github.com/openwrt/openwrt/archive/master.tar.gz  package/utils/ucode/Makefile

# BUG: no build: static-libs, static-bin

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
PV="0.0.20250529"
PV="2026.01.16"
HASH="85922056ef7abeace3cca3ab28bc1ac2d88e31b1"  # 2026.01.16
SRC_URI="https://github.com/jow-/${PN}/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
SRC_URI="
  https://github.com/jow-/${PN}/archive/${HASH}.tar.gz -> ${PN}-${PV}.tar.gz
  http://localhost/pub/distfiles/patch/${PN}-${PV}/100-add-include-for-older-kernels.patch
  http://localhost/pub/distfiles/patch/${PN}-${PV}/110-uloop-allow-reusing-the-existing-environment.patch
  http://localhost/pub/distfiles/patch/${PN}-${PV}/111-uloop-add-optional-setup-callback-to-process.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
inst="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-static +static-libs +shared -doc (+musl) +stest +strip"
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
  "app-admin/uci  # optional" \
  "app-crypt/libmd  # (for digest) optional" \
  "dev-build/cmake3" \
  "dev-libs/json-c" \
  "dev-libs/libnl-tiny1  # (needed ubox) optional" \
  "dev-libs/libubox  # optional" \
  "dev-util/pkgconf" \
  "sys-apps/ubus  # optional" \
  "sys-apps/ubox  # (for libnl) optional" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib  # (zlib-plugin) optional" \
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
  #append-ldflags "-s -static --static"  # no build
  append-cflags -ffunction-sections -fdata-sections
  append-flags -DNDEBUG -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  append-cflags -I${BUILD_DIR}/include/ucode  # FIX: missing headers

  CC="gcc"

  use 'strip' && inst="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  for F in "${FILESDIR}/"*".patch" "${PDIR%/}/patches/"*".diff"; do
    case ${F} in *'*'*) continue;; esac
    [ -f "${F}" ] && patch -p1 -E < "${F}"
  done

  ubox="/$(get_libdir)/libubox.so"  # libubox
  ubus="/$(get_libdir)/libubus.so"
  ucode="/$(get_libdir)/libucode.so"
  blobmsg_json="/$(get_libdir)/libblobmsg_json.so"
  uci="/$(get_libdir)/libuci.so"
  libnl="/$(get_libdir)/libnl-tiny.so"
  libmd="/$(get_libdir)/libmd.so"
  json="/$(get_libdir)/libjson-c.so"
  json_a="/$(get_libdir)/libjson-c.a"

  sed \
    -e "s|(libucode uc_defines \${JSONC_LINK_LIBRARIES})$|(libucode uc_defines ${json})|" \
    -e "s|(libucode-static uc_defines \${JSONC_LINK_LIBRARIES})$|(libucode-static uc_defines ${json_a})|" \
    -e "s|(debug_lib \${libubox} \${libucode})$|(debug_lib ${ubox} libucode)|" \
    -e "s|(ubus_lib \${libubus} \${libblobmsg_json})$|(ubus_lib ${ubus} ${blobmsg_json})|" \
    -e "s|(uci_lib \${libuci} \${libubox})$|(uci_lib ${uci} ${ubox})|" \
    -e "s|(rtnl_lib \${libnl_tiny} \${libubox})$|(rtnl_lib ${libnl} ${ubox})|" \
    -e "s|(nl80211_lib \${libnl_tiny} \${libubox})$|(nl80211_lib ${libnl} ${ubox})|" \
    -e "s|(uloop_lib \${libubox})$|(uloop_lib ${ubox})|" \
    -e "s|(log_lib \${libubox})$|(log_lib ${ubox})|" \
    -i CMakeLists.txt

  cmake -B build -G "Unix Makefiles" \
    -D CMAKE_INSTALL_PREFIX="/usr" \
    -D CMAKE_BUILD_TYPE="None" \
    -D DEBUG_SUPPORT=ON \
    -D DIGEST_SUPPORT=ON \
    -D DIGEST_SUPPORT_EXTENDED=ON \
    -D FS_SUPPORT=ON \
    -D LOG_SUPPORT=ON \
    -D MATH_SUPPORT=ON \
    -D NL80211_SUPPORT=ON \
    -D RESOLV_SUPPORT=ON \
    -D RTNL_SUPPORT=ON \
    -D SOCKET_SUPPORT=ON \
    -D STRUCT_SUPPORT=ON \
    -D UBUS_SUPPORT=OFF \
    -D UCI_SUPPORT=ON \
    -D ULOOP_SUPPORT=ON \
    -D ZLIB_SUPPORT=ON \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -W no-dev \
    || die "Failed cmake build"

  sed \
    -e 's|libjson-c.so$|libjson-c.a|' \
    -e 's|.so$|.a|' \
    -e 's|libz.a$|libz.so|' \
    -i build/CMakeCache.txt

  DESTDIR="${ED}" cmake --build build --target ${inst} -j "$(nproc)" || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  mv -v -n "usr/bin" .
  mv -v -n "usr/lib" "$(get_libdir)"

  use 'stest' && { bin/${PN} -h || : die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz