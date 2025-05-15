#!/bin/sh
# Copyright (C) 2023-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-02-28 23:00 UTC - last change
# Build with useflag: +static +static-libs -shared +perl -diet +musl +x32

export USER XPN PF PV WORKDIR S PKGNAME DPREFIX BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

DESCRIPTION="Cryptographic library for embedded systems"
HOMEPAGE="https://tls.mbed.org/"
LICENSE="Apache-2.0"  # compatible with GPLv2+, GPLv3
NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:-$PWD}
XPN=${PN}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PV="3.1.0"
PV="3.5.2"
SRC_URI="ftp://mirrors.tera-byte.com/pub/gentoo/distfiles/${PN}-${PV}.tar.gz"
SRC_URI="https://github.com/Mbed-TLS/mbedtls/archive/${PN}-${PV}.tar.gz"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="linux"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static +static-libs -shared -diet (+musl) -doc -test +strip"
IUSE="${IUSE} +cpu_flags_x86_sse2 -programs +threads -perl -python3 -minimal"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
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
ED=${INSTALL_DIR}
SDIR="${PDIR%/}/${SRC_DIR}"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
PKGNAME=${PN}
ZCOMP="gunzip"
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PN}-${PV}"
S="${PDIR%/}/${SRC_DIR}/${PN}-${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
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
  pkginst "dev-libs/dietlibc"
else
  pkginst \
    "sys-libs/musl" \
    "sys-kernel/linux-headers" \
    || die "Failed install build pkg depend... error"
fi

use 'perl' && pkginst "dev-lang/perl"
use 'python3' && pkginst "dev-lang/python3"

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

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  use 'cpu_flags_x86_sse2' &&
  sed -i "s://\(#define MBEDTLS_HAVE_SSE2\):\1:" include/${PN}/${PN}_config.h
  use 'threads' &&
  sed -i \
    -e "s://\(#define MBEDTLS_THREADING_C\):\1:" \
    -e "s://\(#define MBEDTLS_THREADING_PTHREAD\):\1:" \
    include/${PN}/${PN}_config.h

  # bug in privoxy - mbedtls no build
  #MBEDTLS_PK_PARSE_C
  #MBEDTLS_X509_USE_C
  #sed -i "s:\(#define MBEDTLS_PK_PARSE_EC_EXTENDED\)://\1:" include/${PN}/${PN}_config.h

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')
  append-flags -DMBEDTLS_FATAL_WARNINGS=OFF
  #append-flags -DMBEDTLS_HAVE_SSE2=ON

  use 'diet' && PATH="${PATH:+${PATH}:}/opt/diet/bin"

	IFS=${NL}

  #make -j "$(use diet && printf 1 || printf $(cpun) )" \
  #ln -vsf "${INCDIR}/linux" ."/${INCDIR##*/}/"

  . runverb \
  make -j "$(nproc)" \
    CC="$(use diet && printf 'diet -Os gcc -nostdinc' || printf gcc)" \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    PREFIX="${EPREFIX%/}" \
    BINDIR="${EPREFIX%/}/bin" \
    MANDIR="${DPREFIX}/share/man/man1" \
    DESTDIR="${ED}" \
    $(usex 'shared' SHARED="1") \
    MBEDTLS_TEST_OBJS="" lib || die "Failed make build or install... error"
    #-C library programs || die "Failed make build or install... error"

  #. runverb \
  #make DESTDIR="${ED}" install || die "make install... error"

  mkdir -pm 0755 "${ED}/usr/include/${PN}/"
  cp -rp include/${PN} "${ED}/usr/include/"
  mkdir -pm 0755 "${ED}/usr/include/psa/"
  cp -rp include/psa "${ED}/usr/include/"
  mkdir -pm 0755 "${ED}/$(get_libdir)"
  cp -RP library/lib${PN}.*      "${ED}/$(get_libdir)/"
  cp -RP library/libmbedx509.*   "${ED}/$(get_libdir)/"
  cp -RP library/libmbedcrypto.* "${ED}/$(get_libdir)/"
  # legacy for privoxy
  ln -s "${PN}_config.h" "${ED}/usr/include/${PN}/config.h"

  cd "${ED}/" || die "install dir: not found... error"

  use 'shared' && strip --verbose --strip-all "$(get_libdir)/"*.so
  if use 'static-libs' || ! use 'shared'; then
    strip --strip-unneeded  "$(get_libdir)/"*.a
  else
    rm -- "$(get_libdir)/"*.a
  fi

  test -d "usr/share" && rm -vr -- "usr/share"

  use 'static' && LD_LIBRARY_PATH=
  test -x "bin/${PN}" && bin/${PN} -v

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

if test -x "bin/${PN}"; then
  ldd "bin/${PN}" || { use 'static' && true;}
fi

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
