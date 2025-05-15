#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-04-19 14:00 UTC - last change
# Build with useflag: +static -crypt -doc -xstub +musl +stest +strip +x32

inherit build qt4-build python pkg-export build-functions

export USER XPN PF PV WORKDIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${PN}
XPN="${6:-${XPN:?}}"
PV="3.0"
XPV="30"
DESCRIPTION="Info ZIP (encryption support)"
HOMEPAGE="https://infozip.sourceforge.net/Zip.html"
SRC_URI="
  https://downloads.sourceforge.net/infozip/${PN}${XPV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/app-arch/zip/files/${PN}-${PV}-no-crypt.patch
  http://data.gpo.zugaina.org/gentoo/app-arch/zip/files/${PN}-${PV}-pic.patch
  http://data.gpo.zugaina.org/gentoo/app-arch/zip/files/${PN}-${PV}-exec-stack.patch
  http://data.gpo.zugaina.org/gentoo/app-arch/zip/files/${PN}-${PV}-build.patch
  http://data.gpo.zugaina.org/gentoo/app-arch/zip/files/${PN}-${PV}-zipnote-freeze.patch
  http://data.gpo.zugaina.org/gentoo/app-arch/zip/files/${PN}-${PV}-format-security.patch
"
LICENSE="Info-ZIP"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
HOSTNAME="linux"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static (+musl) -bzip2 -crypt -natspec -unicode (-doc) -xstub +stest (-test) +strip"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
P="${P:-${XPWD##*/}}"
SN=${P}
PN="${PN:-${P%%_*}}"
PN=${12:-$PN}
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
ZCOMP=$(zcomp-as "${PF}")
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}${XPV}"
S="${PDIR%/}/${SRC_DIR}/${PN}${XPV}"
PWD=${PWD%/}; PWD=${PWD:-/}
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
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl0" \
  || die "Failed install build pkg depend... error"

use 'bzip2' && pkginst "app-arch/bzip2"
use 'natspec' && pkginst "dev-libs/libnatspec"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  for F in "${FILESDIR}/"*".patch"; do
    test -f "${F}" && patch -p1 -E < "${F}"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
    append-ldflags "-s -static --static"
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  append-cppflags \
    -DLARGE_FILE_SUPPORT \
    -DUIDGID_NOT_16BIT \
    -D$(usex !bzip2 'NO_')BZIP2_SUPPORT \
    -D$(usex !crypt 'NO_')CRYPT \
    -D$(usex !unicode 'NO_')UNICODE_SUPPORT

  sh ./unix/configure "gcc" "-I. -DUNIX ${CFLAGS} ${LDFLAGS} ${CPPFLAGS}"

  if use 'bzip2' ; then
    sed -i "s:LFLAGS2=:&'-lbz2 ':" flags || die
  fi

  use 'static' && LD_LIBRARY_PATH=

	IFS=${NL}

  make -j "$(nproc --ignore=1)" \
    -f "unix/Makefile" \
    generic_gcc \
    || die "Failed make build"

  mkdir -pm 0755 "${ED}/bin/"

  for X in zip zipcloak zipnote zipsplit; do
    case ${X} in
      zipcloak) use 'crypt' || continue;;
    esac
    test -x "${X}" && cp -l ${X} "${ED}"/bin/
  done
  printf %s\\n "Install... ok"

  cd "${ED}/" || die "install dir: not found... error"

  strip --verbose --strip-all "bin/"*

  use 'static' && LD_LIBRARY_PATH=
  use 'stest' && { bin/${PN} --version || die "binary work... error";}

  ldd "bin/${PN}" || { use 'static' && true;}

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
