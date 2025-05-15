#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-02-15 19:00 UTC - last change
# Build with useflag: +static -shared -lfs +sse2 +asm +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-vpn/tor/tor-0.4.8.14.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Anonymizing overlay network for TCP"
HOMEPAGE="https://www.torproject.org/ https://gitlab.torproject.org/tpo/core/tor/"
LICENSE="BSD GPL-2 GPL-3"
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
PV="0.4.8.12"
PV="0.4.8.14"
PN2="openssl"
PV2="1.1.1w"
PN3="libevent"
PV3="2.1.12"
SRC_URI="
  https://dist.torproject.org/${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/net-vpn/tor/files/tor-0.2.7.4-torrc.sample.patch
  https://www.openssl.org/source/${PN2}-${PV2}.tar.gz
  ftp://mirrors.tera-byte.com/pub/gentoo/distfiles/${PN3}-${PV3}.tar.gz
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
IUSE="-caps -doc -lzma -man -scrypt -seccomp -selinux +server -systemd -tor-hardening -test -zstd"
IUSE="${IUSE} +static -static-libs -shared (+musl) +stest +strip"
IUSE="${IUSE} +sse2 +asm -zlib -ktls"  # for openssl
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
  "dev-lang/perl  # for openssl (needed: musl [shared-libs])" \
  "dev-libs/gmp  # for openssl" \
  "dev-util/pkgconf" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl0" \
  "sys-libs/zlib  # for tor" \
  || die "Failed install build pkg depend... error"

use 'static' || pkginst "dev-libs/openssl3" "dev-libs/libevent"

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

  for PF in *.tar.gz *.tar.xz; do
    case ${PF} in '*'.tar.*) continue;; *.tar.gz) ZCOMP="gunzip";; *.tar.xz) ZCOMP="unxz";; esac
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
    append-ldflags "-s -static --static"
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc$(usex static ' -static --static')"
  CXX="g++$(usex static ' -static --static')"

  use 'strip' && INSTALL_OPTS="install-strip"

  use 'static' && {
  ############################# build: <dev-libs/openssl> #################################

  cd "${WORKDIR}/${PN2}-${PV2}/" || die "builddir: not found... error"

  ./config \
    --prefix="${DPREFIX%/}" \
    --libdir="/$(get_libdir)" \
    $(usex 'x86' 386) \
    $(usex 'sse2' enable-sse2 no-sse2) \
    no-camellia \
    enable-ec no-ec2m no-sm2 no-gost enable-ecdsa enable-ecdh \
    no-srp \
    no-idea \
    no-mdc2 \
    no-rc5 \
    no-ssl3 \
    no-ssl3-method \
    no-rfc3779 \
    no-sctp \
    enable-heartbeats \
    no-weak-ssl-ciphers \
    enable-engine \
    no-tests \
    no-zlib \
    $(usex 'musl' no-async) \
    $(usex 'asm' enable-asm no-asm) \
    no-pic \
    threads \
    no-dso \
    no-shared \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${BUILD_DIR}/${PN2}" INSTALLTOP=${DPREFIX} OPENSSLDIR="/etc/ssl" install \
  || die "make install... error"

  CFLAGS="${CFLAGS} -I${BUILD_DIR}/${PN2}/${INCDIR#/}"
  LDFLAGS="${LDFLAGS} -L${BUILD_DIR}/${PN2}/$(get_libdir) -lcrypto"
  PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:${BUILD_DIR}/${PN2}/$(get_libdir)/pkgconfig"

  ########################### build: <dev-libs/libevent> ################################

  cd "${WORKDIR}/${PN3}-${PV3}-stable/" || die "builddir: not found... error"

  # BUG: env: can't execute <python>: No such file or directory
  # BUG: event_rpcgen.py failed, ./test/regress.gen.\[ch\] will be reused.
  # NOWORK FIX: PYTHON=true \

  ./configure \
    --prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-openssl \
    --enable-static \
    --disable-shared \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"
  make DESTDIR="${BUILD_DIR}/${PN3}" install || die "make install... error"

  CFLAGS="${CFLAGS} -I${BUILD_DIR}/${PN3}/${INCDIR#/}"
  LDFLAGS="${LDFLAGS} -L${BUILD_DIR}/${PN3}/$(get_libdir) -levent"
  PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:${BUILD_DIR}/${PN3}/$(get_libdir)/pkgconfig"
  }

  ############################## build main package ####################################

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --localstatedir="${EPREFIX%/}"/var \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --disable-all-bugs-are-fatal \
    --enable-system-torrc \
    --disable-android \
    --disable-coverage \
    --disable-html-manual \
    --disable-libfuzzer \
    --enable-missing-doc-warnings \
    --disable-module-dirauth \
    --disable-pic \
    --disable-restart-debugging \
    --enable-gpl \
    --enable-module-pow \
    $(use_enable 'man' asciidoc) \
    $(use_enable 'man' manpage) \
    $(use_enable 'lzma') \
    $(use_enable 'scrypt' libscrypt) \
    $(use_enable 'seccomp') \
    $(use_enable 'server' module-relay) \
    $(use_enable 'systemd') \
    $(use_enable 'tor-hardening' gcc-hardening) \
    $(use_enable 'tor-hardening' linker-hardening) \
    $(use_enable 'test' unittests) \
    $(use_enable 'zstd') \
    --with-malloc=system \
    $(usex 'static' --enable-static-tor) \
    $(usex 'static' --enable-static-openssl) \
    --with-openssl-dir="${BUILD_DIR}/${PN2}/$(get_libdir)" \
    --enable-static-libevent \
    --with-libevent-dir="${BUILD_DIR}/${PN3}/$(get_libdir)" \
    --enable-static-zlib \
    --with-zlib-dir="/$(get_libdir)" \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  bin/${PN} --version || die "binary work... error"

  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
