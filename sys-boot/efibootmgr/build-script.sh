#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-03-17 21:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sys-boot/efibootmgr/efibootmgr-18-r1.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="User-space application to modify the EFI boot manager"
HOMEPAGE="https://github.com/rhinstaller/efibootmgr"
LICENSE="GPL-2"
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="18"
SRC_URI="https://github.com/rhboot/efibootmgr/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static -shared -doc (+musl) +stest +strip"
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
PROGS="src/${PN} src/efibootdump"

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
  "dev-libs/popt" \
  "dev-util/pkgconf" \
  "sys-apps/pciutils" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/efivar" \
  "sys-libs/musl0" \
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
  if use !shared || use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-ldflags "-s -static --static"
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  sed -e 's/-Werror //' -i Make.defaults || die

  export EFIDIR="Nullnimi"

  make -j "$(nproc)" PKG_CONFIG="${PKG_CONFIG}" || die "Failed make build"

  mkdir -pm 0755 -- "${ED}"/sbin/
  mv -v -n ${PROGS} -t "${ED}"/sbin/ || die "make install... error"
  printf %s\\n "Install... ok"

  cd "${ED}/" || die "install dir: not found... error"

  strip --verbose --strip-all "sbin/"*

  use 'stest' && { sbin/${PN} --version || die "binary work... error";}
  ldd "sbin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz