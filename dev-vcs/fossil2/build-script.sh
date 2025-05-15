#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-08-21 12:00 UTC - last change
# Build with useflag: +static +gzip -system-zlib -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="Simple, high-reliability, source control management, and more"
HOMEPAGE="https://www.fossil-scm.org/home"
LICENSE="BSD-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPN=${PN}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
TAG="8be0372c1051043761320c8ea8669c3cf320c406e5fe18ad36b7be5f844ca73b"  # Ver: 2.24
TAG="b98ce23d"  # Ver: 2.12.1 - required patches
TAG="c58877d6"  # Ver: 2.11.2
PV="2.19"    # build ok.
PV="2.24"    # build ok.
PV="2.25"    # build ok.
PV="2.12.1"  # build ok. (wikiedit only-js)
PV="2.11.2"  # build ok. (wikiedit nojs)
SRC_URI="ftp://ftp.vectranet.pl/gentoo/distfiles/${PN}-src-${PV}.tar.gz"
SRC_URI="https://fossil-scm.org/home/tarball/fossil-src-2.25.tar.gz"  # last release version
SRC_URI="
  https://fossil-scm.org/home/tarball/${TAG}/fossil-src-${PV}.tar.gz
  http://shellgen.mooo.com/pub/distfiles/patch/${PN}-2.12.0-r01-back-wysiwyg_c.diff
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static (-diet) (+musl) -doc -readline -openssl -system-zlib -debug (-test) +stest +strip"
IUSE="${IUSE} -fusefs -json -system-sqlite -tcl -tcl-stubs tcl-private-stubs -th1-docs -th1-hooks"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
XPWD=${5:-$XPWD}
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/Fossil-${TAG}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-src-${PV}"
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
  "sys-devel/gcc" \
  "sys-devel/make" \
  "#sys-devel/patch  # for patch with fuzz and offset." \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'readline' && pkginst "dev-libs/libedit"
use 'system-sqlite' && pkginst "dev-db/sqlite"
use 'system-zlib' && pkginst "sys-libs/zlib"
use 'openssl' && pkginst "dev-libs/openssl3"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
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
  append-cflags -ffunction-sections -fdata-sections
  append-ldflags -Wl,--gc-sections -s -static --static
  append-flags -Os -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc -static --static"

  cd "${BUILD_DIR}/compat/zlib/" || exit

  ./configure --static || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  #gpatch -p1 -E < ${FILESDIR}/${PN}-2.12.0-r01-back-wysiwyg_c.diff

  # For new ver replace: <--with-zlib=compat/zlib> to <--with-zlib=tree>
  . runverb \
  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --datadir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --with-zlib="compat/zlib" \
    --with-openssl="none" \
    --enable-internal-sqlite \
    --enable-static \
    --disable-fusefs \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  mkdir -pm 0755 -- "${ED}"/bin/
  mv -n ${PN} -t "${ED}"/bin/ || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  strip --verbose --strip-all "bin/${PN}"

  LD_LIBRARY_PATH=
  bin/${PN} version || die "binary work... error"
  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
