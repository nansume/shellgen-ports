#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-19 21:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie +patch -doc -xstub +diet -musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="The network swiss army knife with crypt. (support: dietlibc)"
HOMEPAGE="https://nc110.sourceforge.io"
LICENSE="netcat"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN="netcat"
PROG="nc"
PV="110"
PATCH_VER="1.0"
SRC_URI="
  https://downloads.sourceforge.net/nc110/nc${PV}.tgz -> ${PN}-${PV}.tar.gz
  #ftp://sith.mimuw.edu.pl/pub/users/baggins/IPv6/nc-v6-20000918.patch.gz
  rsync://mirror.bytemark.co.uk/gentoo/distfiles/*/nc-v6-20000918.patch.gz
  #mirror://gentoo/${PN}-${PV}-patches-${PATCH_VER}.tar.bz2
  rsync://mirror.bytemark.co.uk/gentoo/distfiles/*/${PN}-${PV}-patches-${PATCH_VER}.tar.bz2
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-crypt +ipv6 +static -doc +diet (-musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}"
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
  "dev-libs/dietlibc" \
  "#dev-libs/libmix  # for <crypt>" \
  "#net-misc/rsync  # for gentoo-mirror" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-devel/make" \
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

  for PF in *.tar.gz *.tar.bz2; do
    case ${PF} in *.tar.gz) ZCOMP="gunzip";; *.tar.bz2) ZCOMP="bunzip2";; esac
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
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
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="diet -Os gcc -nostdinc"

  PATH="${PATH:+${PATH}:}/opt/diet/bin"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  gunzip -dc "${FILESDIR}"/nc-v6-20000918.patch.gz | patch -p1 -E
  for F in patch/*.patch.bz2; do
    case ${F} in
      */15_*) bunzip2 -dc "${F}" | patch -p0 -E;;
      *) bunzip2 -dc "${F}" | gpatch -p1 -E;;
    esac
  done

  sed -e 's:#define HAVE_BIND:#undef HAVE_BIND:' -i netcat.c
  # bug 34250
  sed -e 's:#define FD_SETSIZE 16:#define FD_SETSIZE 1024:' -i netcat.c

  export XLIBS=""
  export XFLAGS="-DLINUX -DTELNET -DGAPING_SECURITY_HOLE"

  if use 'ipv6'; then
    XFLAGS="${XFLAGS} -DINET6"
  fi

  if use 'static'; then
    export STATIC="-static"
  fi

  if use 'crypt'; then
    XFLAGS="${XFLAGS} -DAESCRYPT"
    XLIBS="${XLIBS} -lmix"
  fi

  make -j "$(nproc)" -e "nc" CC="${CC} ${CFLAGS} ${LDFLAGS}" || die "Failed make build"

  mkdir -m 0755 -- "${ED}"/bin/
  mv -n ${PROG} -t "${ED}"/bin/
  printf %s\\n "Install: ${PN}... ok"

  cd "${ED}/" || die "install dir: not found... error"

  use 'strip' && strip --verbose --strip-all "bin/${PROG}"

  LD_LIBRARY_PATH=
  use 'stest' && { bin/${PROG} -h || : die "binary work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
