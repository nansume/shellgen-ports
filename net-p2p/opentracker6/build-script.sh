#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-26 18:00 UTC - last change
# Build with useflag: +static +whitelist -blacklist -httpdebug -syslog +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="High-performance bittorrent tracker"
HOMEPAGE="http://erdgeist.org/gitweb/opentracker/ http://erdgeist.org/arts/software/opentracker/"
LICENSE="BEER-WARE"  # Author the libowfat is granted compile with opentracker and dist under license BEER-WARE.
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
PV="0.5"
MUSL_PV="1.2.5"
MY_P="unofficial-v${PV}"
SRC_URI="
  https://github.com/flygoast/opentracker/archive/${MY_P}.tar.gz -> ${PN}-${PV}.tar.gz
  http://musl.libc.org/releases/musl-${MUSL_PV}.tar.gz
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-unofficial-v${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
LD_LIBRARY_PATH=

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

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  chown ${BUILD_USER}:${BUILD_USER} "/$(get_libdir)" "/usr/include"
  sw-user || die "Failed package build from user... error"
  exit
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  for PF in *.tar.gz; do
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 ;;
    'x86')   append-flags -m32  ;;
    'amd64') append-flags -m64  ;;
  esac
  append-ldflags -Wl,--gc-sections
  append-cflags -ffunction-sections -fdata-sections
  append-flags -Os -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc"

  #############################################################################

  cd "${WORKDIR}/musl-${MUSL_PV}/" || die "builddir: not found... error"

  ./configure \
    CC="${CC}" \
    CXX="c++" \
    AR="ar" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --syslibdir="${EPREFIX%/}/$(get_libdir)" \
    --enable-wrapper=no \
    --disable-shared \
    --enable-static \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="" install || die "make install... error"

  CFLAGS="${CFLAGS} -I${INCDIR}"
  LDFLAGS="${LDFLAGS} -L/$(get_libdir) -lc"

  #############################################################################

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  sed \
    -e "s|^FEATURES|#FEATURES|g" \
    -e "s|-O3|-Os|g" \
    -e "/all: / s| \$(BINARY).debug||" \
    -e "s|strip \$@||g" \
    -e "s|-lpthread||g" \
    -e "s|-lz||g" \
    -e "/-DWANT_ACCESSLIST_WHITE/ s|^#FEATURES|FEATURES|" \
    -e "/-DWANT_V6/ s|^#FEATURES|FEATURES|" \
    -i Makefile || die "sed for src_prepare failed"

  make -j1 CC="${CC}" || die "Failed make build"

  /bin/strip --strip-all ${PN}
  ./${PN} ---

  mkdir -pm 0755 "${ED}/bin/"
  mv -n ${PN} "${ED}/bin/"

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
