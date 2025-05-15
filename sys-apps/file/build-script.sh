#!/bin/sh
# Copyright (C) 2023-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2023-12-15 08:00 UTC - last change
# Build with useflag: +static +static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sys-apps/file/file-5.46-r2.ebuild

# Warning! Required fix to build with [static-bin]+[static-lib]+[shared-lib]

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="Identify a file's format by scanning binary data for patterns"
HOMEPAGE="https://www.darwinsys.com/file/"
LICENSE="BSD-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}; #PN="<pkgname> ${PN%-*} ${PN%[0-9]*} PN=${PN/-/_}"
PV="5.41"
SRC_URI="http://ftp.astron.com/pub/${PN}/${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-rpath -nls -bzip2 -lzip -lzma -python -seccomp -zlib -zstd"
IUSE="${IUSE} +static +static-libs +shared -doc (+musl) +stest +strip"
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

use 'bootstrap' && tc-bootstrap-musl "$(arch)-linux-musl$(usex x32 x32 '')-native.tgz"

pkginst \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl0" \
  || die "Failed install build pkg depend... error"

use 'bootstrap' || pkginst "sys-devel/gcc"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"  # only for user-build

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use !shared && { use 'static-libs' || use 'static' ;}; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS='install-strip'
  #use 'x86' && IUSE="${IUSE} +static"

  cp -drp "${BUILD_DIR}" "${BUILD_DIR}-static"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  ###################################################################

  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'bzip2' bzlib) \
    $(use_enable 'xz' xzlib) \
    $(use_enable 'zlib') \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  ###################################################################

  use 'static' && {

  cd "${BUILD_DIR}-static/" || die "builddir: not found... error"

  append-ldflags -Wl,--gc-sections
  append-cflags -ffunction-sections -fdata-sections
  append-ldflags "-s -static --static"

  CFLAGS=${CFLAGS/-O?/-Os} \
  CXXFLAGS=${CXXFLAGS/-O?/-Os} \
  FFLAGS=${FFLAGS/-O?/-Os} \
  FCFLAGS=${FCFLAGS/-O?/-Os} \
  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'bzip2' bzlib) \
    $(use_enable 'xz' xzlib) \
    $(use_enable 'zlib') \
    --disable-shared \
    --enable-static \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"
  }

  ###################################################################

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -r -- "usr/share/man/"

  # simple test
  if use 'static'; then
    LD_LIBRARY_PATH=
  else
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH} }${ED}/$(get_libdir)"
  fi
  bin/${PN} --version || die "binary work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

ldd bin/${PN} || { use 'static' && true;}

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz