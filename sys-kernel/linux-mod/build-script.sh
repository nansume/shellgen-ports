#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-12-23 13:00 UTC - last change
# Build with useflag: -lfs +nopie -patch -doc -xstub -diet -musl +stest +strip -x32 (+amd64)

# <orig-url-build-script>

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="<pkgdesc>"
HOMEPAGE="https://www.kernel.org"
LICENSE="GPL-2.0"
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
PV="5.8.9"
SRC_URI="https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-${PV}.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN%-*}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
#KBUILD_BUILD_HOST="linux"
#KBUILD_VERBOSE="1"
KDATE=$(date '+%Y%m%d')

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
  "app-arch/xz  # required" \
  "#dev-lang/perl  # optional" \
  "dev-util/byacc  # alternative a bison (posix)" \
  "dev-util/pkgconf  # optional" \
  "sys-apps/findutils  # FIX: find busybox no support" \
  "sys-apps/kmod  # required depmod or depmod-bb (busybox)" \
  "sys-devel/binutils9" \
  "sys-devel/flex  # required no-posix lex" \
  "sys-devel/gcc9  # gcc14 no comat with pre kernel modules" \
  "sys-devel/m4  # required for lex" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl  # required headers" \
  "sys-libs/musl  # required headers" \
  "sys-libs/ncurses  # menuconfig, optional" \
  "#sys-libs/netbsd-curses  # menuconfig, optional" \
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
  append-flags -O2
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++" #export XZ="/bin/xz"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  for P in "${PDIR%/}/dist-src/"* "${PDIR%/}/dist-src/".[!.]*; do
    [ -e "${P}" ] && { cp -ulr "${P}" "${BUILD_DIR}/" && printf %s\\n "cp -ulr ${P} ${BUILD_DIR}/" ;}
  done

  sed -e '/^\tselect\ DEBUG_KERNEL$/d' -i init/Kconfig
  sed -e '/^\tselect\ CRYPTO_LZO$/d' -i drivers/block/zram/Kconfig
  sed -e '/^\tselect\ CPU_FREQ_GOV_PERFORMANCE$/d' -i drivers/cpufreq/Kconfig

  { [ -f '.config' ] && [ ! -e 'vmlinuz' ] ;} && { printf '%s\n' "make oldconfig"; make oldconfig;}

  printf '%s\n' "make menuconfig"
  make menuconfig >&0 || die "configure... error"
  reset
  #printf '%s\n' "make config"
  #make config

  # fix for busybox
  sed -e 's!\([^A-z_.-]\)\(find\)\([^A-z_.-]\)!\1/bin/\2\3!' -i usr/gen_initramfs.sh
  sed -e '/^XZ[[:space:]]/ s|=.*$|= /bin/xz|' -i Makefile

  make -j "$(nproc)" || die "Failed make build"

  make \
    INSTALL_MOD_PATH="${ED}" \
    $(usex 'strip' INSTALL_MOD_STRIP=1) \
    modules_install || die "make install... error"

  set -o 'xtrace'
  cp -n '.config' ${ED}/lib/modules/${PV}/
  { set +o 'xtrace';} >/dev/null 2>&1

  cd "${ED}/" || die "install dir: not found... error"

  # if depmod not busybox
  for X in lib/modules/${PV}/modules.*; do
    case ${X##*/} in modules.builtin|modules.builtin.modinfo|modules.dep|modules.order) continue;; *'*'|*);; esac
    [ -d "${X}" ] || rm -v -- "${X}"
  done

  rm -v -- "lib/modules/${PV}/build" "lib/modules/${PV}/source"

  modgen-dep "lib/modules/${PV}"

  exit 0  # only for user-build
fi
# root

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV="${PV}-${KDATE}" pkg-create-cgz

#######################################################################

KNAME=${PN#*-}
PN=${PN%-*}
ZCOMP="xz"
XABI="$(tc-abi-build)"
PKG_DIR=${PKG_DIR:-/pkg}

cd "${BUILD_DIR}/" || die "builddir: not found... error"

set -o 'xtrace'
cp -n 'arch/x86/boot/bzImage' ${PKG_DIR}/${CATEGORY}/${PN}-${KNAME}_${PV}-${KDATE}_${XABI}.${ZCOMP}
{ set +o 'xtrace';} >/dev/null 2>&1
