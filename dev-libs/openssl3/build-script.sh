#!/bin/sh
# Copyright (C) 2021-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2023-11-07 21:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-libs/openssl/openssl-3.3.3.ebuild

# NO-USE: -ffast-math

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="Full-strength general purpose cryptography library (including SSL and TLS)"
HOMEPAGE="https://www.openssl.org/"
LICENSE="Apache-2.0"  # compatible with GPL-3
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
PV="3.1.1"
PV="3.4.1"
SRC_URI="https://www.openssl.org/source/${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+asm +rfc3779 -fips -ktls -quic -sctp +cpu_flags_x86_sse2 +tls-compression +tls-heartbeat"
IUSE="${IUSE} -weak-ssl-ciphers -sslv3 -pic -test -vanilla +sse2 +zlib"
IUSE="${IUSE} -rpath -nls -static +static-libs +shared -doc (+musl) +stest +strip"
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

pkginst \
  "dev-lang/perl" \
  "dev-libs/gmp  # optional" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl0" \
  "sys-libs/zlib  # optional" \
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
  if use 'static' || { use !shared && use 'static-libs' ;}; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"
  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  . runverb \
  ./config \
    --prefix="${DPREFIX%/}" \
    --libdir="/$(get_libdir)" \
    $(usex 'x86' 386) \
    $(usex 'x86' linux-x86 $(usex 'x32' linux-x32 linux-x86_64) ) \
    $(usex 'sse2' enable-sse2 no-sse2) \
    $(usex !doc no-docs) \
    $(usex 'quic' enable-quic no-quic) \
    enable-camellia \
    enable-ec enable-ec2m enable-sm2 \
    enable-srp \
    enable-idea \
    enable-mdc2 \
    no-rc5 \
    $(usex 'fips' enable-fips no-fips) \
    $(usex 'ktls' enable-ktls no-ktls) \
    $(usex 'rfc3779' enable-rfc3779 no-rfc3779) \
    $(usex 'sctp' enable-sctp no-sctp) \
    $(usex 'weak-ssl-ciphers' enable-weak-ssl-ciphers no-weak-ssl-ciphers) \
    $(usex 'test' '' no-tests) \
    $(usex 'zlib' zlib-dynamic) \
    $(usex 'musl' no-async) \
    $(usex 'asm' enable-asm no-asm) \
    $(usex 'shared' '' no-pic) \
    threads \
    $(usex !shared no-shared) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" INSTALLTOP=${DPREFIX} OPENSSLDIR='/etc/ssl' install \
  || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  mv -n "${DPREFIX#/}/bin" .
  rm -r -- "usr/share/" "etc/ssl/ct_log_list.cnf"* "etc/ssl/openssl.cnf.dist"
  use 'strip' && pkg-strip

  # simple test
  if use 'static'; then
    LD_LIBRARY_PATH=
  else
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH} }:${ED}/$(get_libdir)"
  fi
  bin/${PN} version || die "binary work... error"
  ldd "bin/${PN}" || { use 'static' && true;}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz