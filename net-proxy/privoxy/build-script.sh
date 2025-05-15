#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-02-28 23:00 UTC - last change
# Build with useflag: +static +mbedtls -openssl +acl -diet +musl +x32

export USER XPN PF PV WORKDIR S PKGNAME DPREFIX BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:-$PWD}
XPN=${PN}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PV="3.0.34"
DESCRIPTION="A web proxy with advanced filtering capabilities for enhancing privacy"
HOMEPAGE="https://www.privoxy.org https://sourceforge.net/projects/ijbswa/"
SRC_URI="
  https://www.silvester.org.uk/${PN}/Sources/${PV}%20%28stable%29/${PN}-${PV}-stable-src.tar.gz
  http://data.gpo.zugaina.org/gentoo/net-proxy/${PN}/files/${PN}-3.0.32-gentoo.patch
  http://data.gpo.zugaina.org/gentoo/net-proxy/${PN}/files/${PN}-3.0.28-strip.patch
  #http://data.gpo.zugaina.org/gentoo/net-proxy/${PN}/files/${PN}-3.0.33-configure-msan.patch
  http://data.gpo.zugaina.org/gentoo/net-proxy/${PN}/files/${PN}-3.0.33-configure-c99.patch
"
LICENSE="GPL-2+"  # compatible OpenSSL3 or MbedTLS under license Apache-2.0
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="linux"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static (+musl) +ipv6 +compression +zlib (-debug) (-test) +strip"
IUSE="${IUSE} +acl +whitelists -brotli +client-tags +editor -extended-host-patterns"
IUSE="${IUSE} -extended-statistics +external-filters +fast-redirects +force -fuzz"
IUSE="${IUSE} -graceful-termination +image-blocking +jit -lfs +mbedtls -openssl"
IUSE="${IUSE} +png-images -sanitize -selinux +ssl +stats +threads +toggle -tools"
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
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}-stable"
S="${PDIR%/}/${SRC_DIR}/${PN}-${PV}-stable"
PWD=${PWD%/}; PWD=${PWD:-/}
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
  "dev-lang/perl" \
  "dev-libs/pcre" \
  "sys-devel/autoconf" \
  "sys-devel/automake" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/gettext" \
  "sys-devel/m4" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'brotli' && pkginst "app-arch/brotli"
use 'mbedtls' && pkginst "net-libs/mbedtls-compat"  # mbedtls-2.28.7
use 'openssl' && pkginst "dev-libs/openssl3"
use 'zlib' && pkginst "sys-libs/zlib"
use 'selinux' && pkginst "sec-policy/selinux-privoxy"
use 'tools' && pkginst "net-misc/curl"

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

  patch -p1 -E < "${FILESDIR}"/${PN}-3.0.32-gentoo.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-3.0.28-strip.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-3.0.33-configure-c99.patch

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

  use 'strip' && INSTALL_OPTS="install-strip"

	IFS=${NL}

  mv configure.in configure.ac || die
  sed -i "s|/p\.p/|/config.privoxy.org/|g" tools/privoxy-regression-test.pl || die

  autoreconf --install

  . runverb \
  ./configure \
    CC="gcc" \
    --prefix="${EPREFIX%/}" \
    --sbindir="${EPREFIX%/}/sbin" \
    --sysconfdir="/etc/${PN}" \
    --datarootdir="${DPREFIX}/share" \
    --docdir="${DPREFIX}/share/doc/${PN}" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-accept-filter \
    --enable-dynamic-pcre \
    --without-assertions \
    --with-user="privoxy" \
    --with-group="privoxy" \
    $(use_enable 'acl' acl-support) \
    $(use_enable 'compression') \
    $(use_enable 'client-tags') \
    $(use_enable 'editor') \
    $(use_enable 'extended-host-patterns' pcre-host-patterns) \
    $(use_enable 'extended-statistics') \
    $(use_enable 'fast-redirects') \
    $(use_enable 'force') \
    $(use_enable 'fuzz') \
    $(use_enable 'graceful-termination') \
    $(use_enable 'image-blocking') \
    $(use_enable 'jit' pcre-jit-compilation) \
    $(use_enable 'ipv6' ipv6-support) \
    $(use_with 'mbedtls') \
    $(use_with 'openssl') \
    $(use_enable 'lfs' large-file-support) \
    $(use_enable 'png-images' no-gifs) \
    $(use_enable 'stats') \
    $(use_enable 'threads' pthread) \
    $(use_enable 'toggle') \
    $(use_enable 'whitelists' trust-files) \
    $(use_enable 'zlib') \
    $(use_with 'brotli') \
    $(use_enable 'external-filters') \
    $(use_with 'openssl') \
    $(use_enable 'static' static-linking) \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    || die "configure... error"

  make -j "$(cpun)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  rmdir "var/run/" || die

  use 'static' && LD_LIBRARY_PATH=
  sbin/${PN} --version

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

ldd "sbin/${PN}" || { use 'static' && true;}

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
