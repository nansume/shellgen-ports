#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-12 19:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="GNU Common C++ 2"
HOMEPAGE="http://www.gnu.org/software/commoncpp/"
LICENSE="GPL-2"
DOCS="ChangeLog COPYING.addendum"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="1.8.1"
SRC_URI="
  mirror://gnu/commoncpp/${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/nest/dev-cpp/commoncpp2/files/1.8.1-autoconf-update.patch
  http://data.gpo.zugaina.org/nest/dev-cpp/commoncpp2/files/1.8.1-configure_detect_netfilter.patch
  http://data.gpo.zugaina.org/nest/dev-cpp/commoncpp2/files/1.8.0-glibc212.patch
  http://data.gpo.zugaina.org/nest/dev-cpp/commoncpp2/files/1.8.1-fix-buffer-overflow.patch
  http://data.gpo.zugaina.org/nest/dev-cpp/commoncpp2/files/1.8.1-parallel-build.patch
  http://data.gpo.zugaina.org/nest/dev-cpp/commoncpp2/files/1.8.1-libgcrypt.patch
  http://data.gpo.zugaina.org/nest/dev-cpp/commoncpp2/files/1.8.1-fix-c++14.patch
  http://data.gpo.zugaina.org/nest/dev-cpp/commoncpp2/files/1.8.1-gnutls-3.4.patch
  http://data.gpo.zugaina.org/nest/dev-cpp/commoncpp2/files/1.8.1-openssl-1.1.patch
  http://data.gpo.zugaina.org/nest/dev-cpp/commoncpp2/files/1.8.1-fix-gcc9.patch
  #http://data.gpo.zugaina.org/nest/dev-cpp/commoncpp2/files/1.8.1-c++17.patch
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
IUSE="-debug -doc +gnutls +ipv6 +ssl +static-libs +static +shared -doc (+musl) +stest +strip"
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
  "dev-libs/gmp  # deps gnutls" \
  "dev-libs/libgcrypt  # deps gnutls" \
  "dev-libs/libgpg-error  # deps gnutls" \
  "dev-libs/libtasn1  # deps gnutls" \
  "dev-libs/libunistring  # deps gnutls" \
  "dev-libs/nettle  # deps gnutls" \
  "net-libs/gnutls" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
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
  if use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/1.8.1-autoconf-update.patch
  patch -p1 -E < "${FILESDIR}"/1.8.1-configure_detect_netfilter.patch
  gpatch -p1 -E < "${FILESDIR}"/1.8.0-glibc212.patch
  patch -p1 -E < "${FILESDIR}"/1.8.1-fix-buffer-overflow.patch
  patch -p1 -E < "${FILESDIR}"/1.8.1-parallel-build.patch
  patch -p1 -E < "${FILESDIR}"/1.8.1-libgcrypt.patch
  patch -p1 -E < "${FILESDIR}"/1.8.1-fix-c++14.patch
  patch -p1 -E < "${FILESDIR}"/1.8.1-gnutls-3.4.patch
  patch -p1 -E < "${FILESDIR}"/1.8.1-openssl-1.1.patch
  patch -p1 -E < "${FILESDIR}"/1.8.1-fix-gcc9.patch
  #patch -p1 -E < "${FILESDIR}"/1.8.1-c++17.patch

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --host=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
    --build=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
    $(use_enable 'debug') \
    $(use_with 'ipv6') \
    $(use_with 'ssl' $(usex gnutls gnutls openssl)) \
    $(: use_with 'doc' doxygen) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  use 'doc' && export HTML_DOCS="doc/html/."

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -vr -- "usr/share/info/"

  find "$(get_libdir)/" -name '*.la' -delete || die "find failed"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
