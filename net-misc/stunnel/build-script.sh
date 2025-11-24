#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2023-12-17 01:00 UTC, 2025-07-10 06:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-misc/stunnel/stunnel-5.75.ebuild

# ------------------------------------------------------------------------------
# https://lite.duckduckgo.com/lite?q=stunnel+libwrap+multiple+processes&kl=us-en
# Stunnel 4 Multiple Processes on Ubuntu 8.04
# https://www.stunnel.org/pipermail/stunnel-users/2008-May/001977.html
# Why 6 processes for single client-mode service configuration?
# https://www.stunnel.org/pipermail/stunnel-users/2011-October/003281.html
# ------------------------------------------------------------------------------
# Question: Why I've now got so many processes?
# Answer:
#  These are internal libwrap servers.  As libwrap code is not MT-safe these
#  servers provide libwrap functionality to stunnel threads.
# ------------------------------------------------------------------------------
# TIP: +5 processes for libwrap mode - runtime
# ------------------------------------------------------------------------------

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="TLS/SSL - Port Wrapper"
HOMEPAGE="https://www.stunnel.org/index.html"
LICENSE="GPL-2-with-OpenSSL-exception"  # only to OpenSSL-1.1.1, starting OpenSSL-3.0.0 no compatible?
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
PV="5.68"
PV="5.75"
SRC_URI="ftp://ftp.vectranet.pl/gentoo/distfiles/${PN}-${PV}.tar.gz"
SRC_URI="
  https://www.stunnel.org/downloads/${PN}-${PV}.tar.gz
  http://ftp.debian.org/debian/pool/main/s/stunnel4/stunnel4_5.74-2.debian.tar.xz
  http://data.gpo.zugaina.org/gentoo/net-misc/stunnel/files/stunnel-5.71-dont-clobber-fortify-source.patch
  http://data.gpo.zugaina.org/gentoo/net-misc/stunnel/files/stunnel-5.71-respect-EPYTHON-for-tests.patch
  http://data.gpo.zugaina.org/gentoo/net-misc/stunnel/files/stunnel.conf
  http://data.gpo.zugaina.org/gentoo/net-misc/stunnel/files/stunnel-r2 -> stunnel-r2-openrc.sample
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
# static linking with OpenSSL no restricted?
IUSE="+ipv6 -selinux -pic -stunnel3 -systemd +tcpd -test"
IUSE="${IUSE} +static -shared -doc (+musl) +stest +strip"
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
IONICE_COMM="nice -n 19"

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
  "#dev-build/autoconf-archive  # for F_S patch" \
  "dev-libs/gmp  # deps openssl" \
  "dev-libs/openssl1  # (openssl-1.1.1) size: 2.4M" \
  "#dev-libs/openssl3  # TIP: too big size: 4.7M" \
  "sys-apps/file" \
  "sys-devel/binutils9" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl  # optional" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps openssl" \
  || die "Failed install build pkg depend... error"

use 'tcpd' && pkginst "sys-apps/tcp-wrappers"

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
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-ldflags "-s -static --static"
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  . runverb \
  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --enable-ipv6 \
    $(use_enable 'tcpd' libwrap) \
    --disable-fips \
    --disable-systemd \
    --with-threads=pthread \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  rm -v -r -- "usr/" "var/" $(use 'static' && printf "$(get_libdir)/")

  # simple test
  if use 'static'; then
    LD_LIBRARY_PATH=
  else
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH} }:${ED}/$(get_libdir)"
  fi
  use 'stest' && { bin/${PN} -version || die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz