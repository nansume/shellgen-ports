#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-17 19:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl -stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="Pseudo-Random Number Generator library"
HOMEPAGE="http://statmath.wu.ac.at/prng/"
LICENSE="GPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="3.0.2"
SRC_URI="
  http://statmath.wu.ac.at/prng/${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/sci-mathematics/prng/files/prng-3.0.2-shared.patch
  http://data.gpo.zugaina.org/gentoo/sci-mathematics/prng/files/prng-3.0.2-fix-all-c99-inline-semantics.patch
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
IUSE="-doc -examples +static-libs +shared (+musl) +strip"
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
  "dev-lang/perl  # required for autotools" \
  "sys-apps/file" \
  "sys-devel/autoconf  # required for autotools" \
  "sys-devel/automake  # required for autotools" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/libtool  # required for autotools" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-devel/make" \
  "sys-libs/musl" \
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

  CC="gcc"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  gpatch -p1 -E < "${FILESDIR}"/${PN}-3.0.2-shared.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-3.0.2-fix-all-c99-inline-semantics.patch

  test -x "/bin/perl" && autoreconf --install

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --host=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
    --build=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  use 'doc' && dodoc doc/${PN}.pdf
  if use 'examples'; then
    rm examples/Makefile* || die
    dodoc -r examples
    docompress -x /usr/share/doc/${PN}-${PV}/examples
  fi

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -r -- usr/info/

  if ! use 'static-libs'; then
    find "$(get_libdir)/" -name '*.la' -delete || die
  fi

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
