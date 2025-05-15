#!/bin/sh
# Copyright (C) 2023-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2024-01-16 14:00 UTC - last change
# Build with useflag: -standalone +static -static-libs -shared -lfs +nopie +patch -doc -diet +musl +stest +strip +x32

# TODO: bump to dropbear-2025.88 with fix build bug.
# TESTING (for openwrt-23.05.5): enabled build flag: append-cflags -DDROPBEAR_DH_GROUP14_SHA256=1

# http://data.gpo.zugaina.org/gentoo/net-misc/dropbear/dropbear-2025.88-r1.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC CXX

DESCRIPTION="small SSH 2 client/server designed for small memory environments"
HOMEPAGE="https://matt.ucc.asn.au/dropbear/dropbear.html"
LICENSE="MIT GPL-2" # (init script is GPL-2 #426056)
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PV="2022.83"
PV="2025.88"  # BUG: no-build with musl libc
PV="2025.87"
SRC_URI="
  https://matt.ucc.asn.au/${PN}/releases/${PN}-${PV}.tar.bz2
  http://data.gpo.zugaina.org/gentoo/net-misc/${PN}/files/${PN}-2024.84-dbscp.patch
  http://data.gpo.zugaina.org/gentoo/net-misc/${PN}/files/${PN}-2024.86-tests.patch
  http://data.gpo.zugaina.org/gentoo/net-misc/${PN}/files/${PN}-2024.84-test-bg-sleep.patch
  http://data.gpo.zugaina.org/gentoo/net-misc/${PN}/files/${PN}-2025.88-remove-which.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
STRIP=":"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-bsdpty +multicall -pam -shadow -utmp +zlib +standalone +inetd +hardening"
# <sha1> required for the openwrt old version.
IUSE="${IUSE} +sha1 +sftp -netcat +cmd -agent +fwd-remote-port -banner +scp +pubkey +passwd"
IUSE="${IUSE} -minimal +syslog -small -test -debug +static -shared -doc (+musl) +stest +strip"
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
ZCOMP="bunzip2"
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
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'zlib' && pkginst "sys-libs/zlib"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

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
  if use !shared && use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && STRIP="strip"
  use 'small' && LTM_CFLAGS=${CFLAGS}

  append-cflags -DNON_INETD_MODE=$(usex 'standalone' 1 0)
  append-cflags -DDROPBEAR_REEXEC=0
  append-cflags -DDEBUG_TRACE=$(usex 'debug' 4 0)
  append-cflags -DDROPBEAR_SMALL_CODE=$(usex 'small' 1 0)
  #append-cflags -DDROPBEAR_CLI_LOCALTCPFWD=0
  #append-cflags -DDROPBEAR_CLI_REMOTETCPFWD=0
  #append-cflags -DDROPBEAR_SVR_LOCALTCPFWD=0
  #append-cflags -DDROPBEAR_SVR_REMOTETCPFWD=0
  append-cflags -DDROPBEAR_SVR_AGENTFWD=0
  append-cflags -DDROPBEAR_CLI_AGENTFWD=0
  #append-cflags -DDROPBEAR_CLI_PROXYCMD=0
  append-cflags -DDROPBEAR_CLI_NETCAT=0
  append-cflags -DDROPBEAR_USER_ALGO_LIST=0
  append-cflags -DDROPBEAR_AES128=$(usex 'sha1' 1 0)
  append-cflags -DDROPBEAR_AES256=0
  append-cflags -DDROPBEAR_ENABLE_CTR_MODE=$(usex 'sha1' 1 0)
  append-cflags -DDROPBEAR_SHA1_HMAC=$(usex 'sha1' 1 0)
  append-cflags -DDROPBEAR_SIGNKEY_RSA=1
  append-cflags -DDROPBEAR_RSA=0
  append-cflags -DDROPBEAR_RSA_SHA1=0
  append-cflags -DDROPBEAR_ECDSA=0
  append-cflags -DDROPBEAR_SK_KEYS=0
  append-cflags -DDROPBEAR_DELAY_HOSTKEY=0
  append-cflags -DDROPBEAR_DH_GROUP14_SHA1=$(usex 'sha1' 1 0)
  append-cflags -DDROPBEAR_DH_GROUP14_SHA256=0
  append-cflags -DDROPBEAR_ECDH=0
  append-cflags -DDROPBEAR_DH_GROUP1=0
  append-cflags -DDO_MOTD=0
  append-cflags -DDROPBEAR_SVR_PASSWORD_AUTH=$(usex 'passwd' 1 0)
  append-cflags -DDROPBEAR_CLI_PASSWORD_AUTH=$(usex 'passwd' 1 0)
  append-cflags -DDROPBEAR_SVR_PUBKEY_AUTH=$(usex 'pubkey' 1 0)
  append-cflags -DDROPBEAR_SVR_PUBKEY_OPTIONS=$(usex 'pubkey' 1 0)
  append-cflags -DDROPBEAR_CLI_PUBKEY_AUTH=$(usex 'pubkey' 1 0)
  append-cflags -DDROPBEAR_USE_PASSWORD_ENV=$(usex 'passwd' 1 0)
  append-cflags -DMAX_UNAUTH_PER_IP=1
  append-cflags -DMAX_UNAUTH_CLIENTS=4
  append-cflags -DMAX_AUTH_TRIES=4
  #append-cflags -DUNAUTH_CLOSE_DELAY=10
  append-cflags -DDROPBEAR_SFTPSERVER=0$(usex 'sftp' 1 0)

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  use 'x32' && patch -p1 -E < "${PDIR%/}/patches/01-${PN}_tomcrypt_${ABI}.diff"
  #patch -p1 -E < "${FILESDIR}"/${PN}-2024.84-dbscp.patch
  #patch -p1 -E < "${FILESDIR}"/${PN}-2024.86-tests.patch
  #patch -p1 -E < "${FILESDIR}"/${PN}-2024.84-test-bg-sleep.patch
  #patch -p1 -E < "${FILESDIR}"/${PN}-2025.88-remove-which.patch

  . runverb \
  ./configure \
    CC="${CC}" \
    LTM_CFLAGS="${LTM_CFLAGS}" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'static') \
    $(use_enable 'zlib') \
    $(use_enable 'syslog') \
    $(use_enable 'shadow') \
    $(use_enable 'hardening' harden) \
    --disable-largefile \
    --disable-lastlog \
    --disable-utmp \
    --disable-utmpx \
    --disable-wtmp \
    --disable-wtmpx \
    --disable-loginfunc \
    --disable-pututline \
    --disable-pututxline \
    || die "configure... error"

  make -j "$(usex diet 1 $(nproc) )" \
    DESTDIR="${ED}" \
    MULTI=$(usex 'multicall' 1 0) \
    PROGRAMS="dropbear dbclient dropbearkey $(usex !minimal 'dropbearconvert scp')" \
    ${STRIP} install || die "Failed make build/install... Error"

  cd "${ED}/" || die "install dir: not found... error"

  IFS="${IFS} "

  for X in dbclient dropbearkey ssh $(usex !minimal 'dropbearconvert scp'); do
    ln -sf "${PN}multi" bin/${X}
  done
  ln -sf "../bin/${PN}multi" sbin/${PN}

  rm -v -r -- "usr/"

  use 'strip' && strip --verbose --strip-all "bin/${PN}multi"

  # simple test
  use 'static' && LD_LIBRARY_PATH=
  if use 'multicall'; then
    bin/${PN}multi ${PN} -V || die "binary work... error"
  else
    sbin/${PN} -V || die "binary work... error"
    bin/ssh -V || die "binary work... error"
  fi

  ldd "bin/${PN}multi" || { use 'static' && true;}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz