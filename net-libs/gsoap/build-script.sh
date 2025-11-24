#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-06-22 15:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-libs/gsoap/gsoap-2.8.130-r1.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="A cross-platform open source C and C++ SDK for SOAP/XML Web services"
HOMEPAGE="http://gsoap2.sourceforge.net"
LICENSE="|| ( gSOAP-1.3b GPL-2+-with-openssl-exception ) GPL-2+"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PV="2.8.138"  # no compat with current patches for musl.
PV="2.8.130"
SRC_URI="
  rsync://mirror.bytemark.co.uk/gentoo/distfiles/*/${PN}_${PV}.zip
  #mirror://gentoo/*/${PN}_${PV}.zip
  #mirror://sourceforge/gsoap2/${PN}_${PV}.zip
  #https://downloads.sourceforge.net/project/gsoap2/gsoap_2.8.138.zip
  http://data.gpo.zugaina.org/gentoo/net-libs/gsoap/files/${PN}-2.8.130-shared_libs.patch
  http://data.gpo.zugaina.org/gentoo/net-libs/gsoap/files/${PN}-2.8.130-musl-strerror_r.patch
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
IUSE="-doc -debug -examples +ipv6 -gnutls +ssl +static-libs +shared (+musl) +stest +strip"
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
ZCOMP="unzip"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV%.*}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
PROG="wsdl2h"

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
  "dev-build/autoconf71  # slot=71,slot=69 - required for autotools" \
  "dev-build/automake16  # slot=16,slot=15 - required for autotools" \
  "dev-build/libtool6  # required for autotools,libtoolize" \
  "dev-lang/perl  # required for autotools" \
  "dev-libs/gmp  # deps ssl" \
  "dev-libs/openssl3" \
  "dev-util/byacc  # alternative a bison (posix)" \
  "net-misc/rsync  # for (mirror://) <mirror-fetch>" \
  "sys-apps/file" \
  "sys-devel/binutils6" \
  "sys-devel/flex" \
  "sys-devel/gcc6" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "#sys-devel/patch  # for patch with fuzz and offset." \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps ssl" \
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

  ${ZCOMP} -qd "${PDIR%/}/${SRC_DIR}/" "${PF}" || exit &&
  printf %s\\n "${ZCOMP} -qd ${PDIR%/}/${SRC_DIR}/ ${PF}"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # Enable shared libs (bug #583398)
  patch -p1 -E < "${FILESDIR}/${PN}-2.8.130-shared_libs.patch"
  # use XSI-compliant version of strerror_r() on musl
  patch -p1 -E < "${FILESDIR}/${PN}-2.8.130-musl-strerror_r.patch"

  chmod +x -- "configure" "install-sh"

  test -x "/bin/perl" && autoreconf -i

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-dependency-tracking \
    --disable-xlocale \
    $(use_enable 'debug') \
    $(use_enable 'gnutls') \
    $(usex 'ipv6' --enable-ipv6) \
    $(usex !ssl --disable-ssl) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'stest' && { bin/${PROG} --help || : die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz