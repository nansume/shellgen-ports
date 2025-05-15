#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-29 17:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC AR

DESCRIPTION="BSD licensed clone of the GNU libc backtrace facility"
HOMEPAGE="https://www.freshports.org/devel/libexecinfo"
LICENSE="BSD-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="1.1"
URL="data.gpo.zugaina.org/dm9pZCAq/dev-libs/libexecinfo/files"
SRC_URI="
  http://distcache.freebsd.org/local-distfiles/itetcu/${PN}-${PV}.tar.bz2
  http://${URL}/define-gnu-source.patch -> libexecinfo-define-gnu-source.patch
  http://${URL}/execinfo.patch -> libexecinfo-execinfo.patch
  http://data.gpo.zugaina.org/dm9pZCAq/dev-libs/libexecinfo/files/libexecinfo_pc.patch
  http://${URL}/makefile.patch -> libexecinfo-makefile.patch
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
IUSE="+musl +static +static-libs +shared -doc +stest +strip"
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
ZCOMP="bunzip2"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
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
  "sys-devel/binutils" \
  "sys-devel/gcc" \
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

  inherit flag-o-matic toolchain-funcs install-functions

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector $(usex 'nopie' -no-pie) -g0 -march=$(arch | sed 's/_/-/')
  append-flags '-fno-omit-frame-pointer'

  CC="cc" AR="ar"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # patches from voidlinux
  for F in "${FILESDIR}/"*".patch"; do
    test -f "${F}" && patch -p0 -E < "${F}"
  done

  sed -i "${PN}.pc" -e "/Version:/s@version@${PV}@" || die

  make -j "$(nproc)" CC="${CC}" AR="${AR}" dynamic $(usex 'static-libs' static) || die "Failed make build"

  insinto "/$(get_libdir)/pkgconfig"
  doins "${PN}.pc"

  doheader *.h

  dolib.so "${PN}.so.1" || die "make install... error"
  dosym "${PN}.so.1" "/$(get_libdir)/${PN}.so"

  use 'static-libs' && dolib.a ${PN}.a

  cd "${ED}/" || die "install dir: not found... error"

  sed \
    -e '/^exec_prefix=/ s|${prefix}||' \
    -e "s|^libdir=.*|libdir=/$(get_libdir)|" \
    -i "$(get_libdir)/"pkgconfig/${PN}.pc

  use 'static-libs' && strip --strip-unneeded "$(get_libdir)/"${PN}.a
  strip --verbose --strip-all "$(get_libdir)/"${PN}.so.1

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
