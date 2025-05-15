#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-08-30 01:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Security sandbox for any type of processes"
HOMEPAGE="https://firejail.wordpress.com/"
LICENSE="GPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="0.9.72"
SRC_URI="
  ftp://mirrors.tera-byte.com/pub/gentoo/distfiles/${PN}-${PV}.tar.xz
  http://data.gpo.zugaina.org/gentoo/sys-apps/firejail/files/firejail-0.9.70-envlimits.patch
  http://data.gpo.zugaina.org/gentoo/sys-apps/firejail/files/firejail-0.9.70-firecfg.config.patch
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
IUSE="-apparmor +chroot -contrib -dbusproxy +file-transfer +globalcfg +network +private-home -selinux"
IUSE="${IUSE} -suid -test -userns +X -man -doc (+musl) +stest +strip"
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
  "dev-util/pkgconf" \
  "sys-apps/gawk  # gawk: not found" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-kernel/linux-headers" \
  "#sys-libs/libseccomp" \
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

  : kernel_check_config "CONFIG_SQUASHFS=*" || echo "CONFIG_SQUASHFS: required for firejail --appimage mode"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}/${PN}-0.9.70-envlimits.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-0.9.70-firecfg.config.patch"

  #--enable-overlayfs  # security risk
  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-fatal-warnings \
    --enable-firetunnel \
    --disable-lts \
    $(use_enable 'suid') \
    $(use_enable 'apparmor') \
    $(use_enable 'chroot') \
    --disable-dbusproxy \
    $(use_enable 'file-transfer') \
    $(use_enable 'globalcfg') \
    $(use_enable 'network') \
    $(use_enable 'private-home') \
    $(use_enable 'selinux') \
    --disable-userns \
    $(use_enable 'X' x11) \
    --enable-busybox-workaround \
    $(use_enable 'man') \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  rm -vr -- "usr/share/bash-completion/" "usr/share/zsh/"

  #chmod u+s bin/${PN}

  #LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)/${PN}"
  use 'stest' && { bin/${PN} --version || : die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || : die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
