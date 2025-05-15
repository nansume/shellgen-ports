#!/bin/sh
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-12-27 14:00 UTC - last change

export USER XPN PF PV WORKDIR PKGNAME DPREFIX BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR S SDIR

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:=$PWD}
XPN=${PN}
PKG_DIR='/pkg'
LC_ALL='C'
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PV="1.0.0"
DESCRIPTION="Set of internet protocol service daemons for Unix"
HOMEPAGE="http://smarden.org/ipsvd/"
SRC_URI="
  http://smarden.org/${PN}/${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/net-misc/${PN}/files/${PN}-${PV}-fix-parallel-make.diff
  http://data.gpo.zugaina.org/gentoo/net-misc/${PN}/files/${PN}-${PV}-fix-musl-clang-16.patch
"
LICENSE="BSD"
USER=${USER:-root}
USE_BUILD_ROOT='0'
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX='/usr'
INCDIR="${DPREFIX}/include"
HOSTNAME='linux'
BUILD_USER='tools'
SRC_DIR='build'
IONICE_COMM='nice -n 19'
ZCOMP='gunzip'
IUSE="+static +diet (-musl) +ipv6 (+patch) +strip"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
DPREFIX="/usr"
XPWD=${5:-$XPWD}
P="${P:-${XPWD##*/}}"
SN=${P}
CATEGORY=${11:-$CATEGORY}
PN="${PN:-${P%%_*}}"
PN=${12:-$PN}
PORTS_DIR=${PWD%/$P}
DISTDIR="/usr/distfiles"
DISTSOURCE="${PDIR%/}/sources"
FILESDIR=${DISTSOURCE}
INSTALL_DIR="${PDIR%/}/install"
S="${PDIR%/}/${SRC_DIR}"
SDIR="${S}"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
PKGNAME=$(pkgname)
ZCOMP=$(zcomp-as "${PF}")
WORKDIR="${PDIR%/}/${SRC_DIR}/net/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
BUILDLIST=${10:-$BUILDLIST}
ABI_BUILD="${ABI_BUILD:-${1:?}}"
XPN="${6:-${XPN:?}}"
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
  || die "Failed install build pkg depend... error"

if use 'diet'; then
  IUSE="${IUSE} +static"
  pkginst "dev-libs/dietlibc"
else
  IUSE="${IUSE} -diet"
  pkginst "sys-libs/musl"
fi

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then

  cd "${DISTSOURCE}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  patch -p1 -E < "${DISTSOURCE}/${PN}-${PV}-fix-parallel-make.diff"
  patch -p1 -E < "${DISTSOURCE}/${PN}-${PV}-fix-musl-clang-16.patch"

  WORKDIR="${WORKDIR}/src"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  if use 'diet'; then
    PATH="${PATH:+${PATH}:}/opt/diet/bin"
    printf %s\\n "diet -Os gcc -nostdinc ${CFLAGS}" > conf-cc || die
    printf %s\\n "diet -Os gcc -nostdinc ${LDFLAGS}" > conf-ld || die
  else
    printf %s\\n "gcc$(use static && printf ' -static --static') ${CFLAGS}" > conf-cc || die
    printf %s\\n "gcc$(use static && printf ' -s -static --static') ${LDFLAGS}" > conf-ld || die
  fi

	IFS=${NL}

  . runverb \
  make -j "$(cpun)" || die "Failed make build"

  mkdir -pm 0755 "${INSTALL_DIR}/bin/"
  cp -p tcpsvd udpsvd ipsvd-cdb "${INSTALL_DIR}/bin/"
  printf %s\\n "Install... ok"

  cd "${INSTALL_DIR}/" || die "install dir: not found... error"

  strip --verbose --strip-all bin/tcpsvd bin/udpsvd bin/ipsvd-cdb

  # simple test
  use 'static' && LD_LIBRARY_PATH=
  bin/tcpsvd -V

  exit 0
fi

cd "${INSTALL_DIR}/" || die "install dir: not found... error"

ldd "bin/tcpsvd" || { use 'static' && true;}

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
