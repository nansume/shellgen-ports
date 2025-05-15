#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-02-21 19:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-libs/openssl/openssl-1.0.2u-r1.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="Full-strength general purpose cryptography library (including SSL and TLS)"
HOMEPAGE="https://www.openssl.org/"
LICENSE="openssl"  # no compatible GPL, only with-OpenSSL-exception.
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}; PN=${PN%-*}
PV="1.0.2u"
SRC_URI="https://www.openssl.org/source/old/${PV%[a-z]}/${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+asm -bindist +gmp -kerberos +rfc3779 -sctp +cpu_flags_x86_sse2 -sslv2 -sslv3 +static-libs"
IUSE="${IUSE} -test +tls-compression -tls-heartbeat -vanilla -weak-ssl-ciphers"
IUSE="${IUSE} -rpath -nls -static +shared +sse2 -pic +test -doc (+musl) +stest +strip"
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
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector $(usex 'pic' '' -no-pie) -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  test "X${ABI}" = 'Xx32' && export MACHINE=${EABI}

  cd "${BUILD_DIR}/" || die "builddir: not found... error"
  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  . runverb \
  ./config \
    --prefix="${DPREFIX%/}" \
    --libdir="/$(get_libdir)" \
    $(usex 'x86' 386) \
    $(usex 'sse2' enable-sse2 no-sse2) \
    enable-camellia \
    enable-ec enable-ec2m enable-sm2 enable-gost enable-ecdsa enable-ecdh \
    enable-srp \
    enable-idea \
    enable-mdc2 \
    no-rc5 \
    no-ssl3 \
    no-ssl3-method \
    $(usex 'rfc3779' enable-rfc3779 no-rfc3779) \
    $(usex 'sctp' enable-sctp no-sctp) \
    $(usex 'heartbeats' enable-heartbeats) \
    $(usex 'weak-ssl-ciphers' enable-weak-ssl-ciphers no-weak-ssl-ciphers) \
    enable-engine \
    $(usex 'test' '' no-tests) \
    $(usex 'zlib' zlib-dynamic no-zlib) \
    $(usex 'musl' no-async) \
    $(usex 'x32' no-asm enable-asm) \
    $(usex 'shared' '' no-pic) \
    threads \
    $(usex 'static' no-dso) \
    $(usex 'static' no-shared) \
    $(usex 'static' static shared) \
    || die "configure... error"

  # add: support x32
  if test "X$(tc-abi-build)" = 'Xx32'; then
    LDFLAGS='-mx32'
  fi
  # Clean out hardcoded flags that openssl uses
  DEFAULT_CFLAGS=$(grep ^CFLAG= Makefile | LC_ALL=C sed \
    -e 's:^CFLAG=::' \
    -e 's:\(^\| \)-fomit-frame-pointer::g' \
    -e 's:\(^\| \)-O[^ ]*::g' \
    -e 's:\(^\| \)-march=[^ ]*::g' \
    -e 's:\(^\| \)-mcpu=[^ ]*::g' \
    -e 's:\(^\| \)-m[^ ]*::g' \
    -e 's:^ *::' \
    -e 's: *$::' \
    -e 's: \+: :g' \
    -e 's:\\:\\\\:g'
  )
  # Now insert clean default flags with user flags
  sed \
    -e "/^CFLAG/s|=.*|=${DEFAULT_CFLAGS} ${CFLAGS-}|" \
    -e "/^LDFLAGS=/s|=[[:space:]]*$|=${LDFLAGS-}|" \
    -e "/^SHARED_LDFLAGS=/s|=-.*$|=${LDFLAGS-}|" \
    -i Makefile

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
