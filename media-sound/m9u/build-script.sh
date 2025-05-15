#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-05-08 15:00 UTC - last change
# Build with useflag: +static +static-libs -shared -lfs +nopie +patch -doc -xstub -diet (+musl) +stest +strip +x32

# http://data.gpo.zugaina.org/booboo/media-sound/m9u/m9u-0.5.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="m9u is designed to be a music server, much like mpd or xmms2. (Plan 9)"
HOMEPAGE="http://sqweek.net/code/m9u/"
LICENSE="ISC"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PV="0.5"
PN1="libixp"
PV1="0.5_p20110208"
SRC_URI="
  http://sqweek.net/9p/${PN}-${PV}.tar.gz
  rsync://mirror.bytemark.co.uk/gentoo/distfiles/*/${PN1}-${PV1}.tar.xz
  http://data.gpo.zugaina.org/gentoo/sys-libs/libixp/files/${PN1}-${PV1}-gentoo.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static -shared -doc (-diet) (+musl) +stest +strip"
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
PROG=${PN}

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
  "net-misc/rsync  # for (mirror://) <mirror-fetch>" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'diet' && {
  pkginst "dev-libs/dietlibc" "sys-libs/libixp"
}

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
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -Os
  append-ldflags -Wl,--gc-sections
  append-cflags -ffunction-sections -fdata-sections
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" AR="ar"

  use 'diet' && {
    CC="diet -Os gcc -nostdinc -I/usr/include"
    PATH="${PATH:+${PATH}:}/opt/diet/bin"
  }

  #############################################################################

  cd "${WORKDIR}/${PN1}-${PV1}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/${PN1}-${PV1}-gentoo.patch

  make -j "$(nproc)" \
    DESTDIR="${ED}" \
    PREFIX="${EPREFIX}/usr" \
    LIBDIR="${EPREFIX}"/$(get_libdir) \
    LIBS= \
    CC="${CC} -c" \
    LD="${CC} ${LDFLAGS}" \
    AR="${AR} crs" \
    MAKESO=$(usex 'shared' 1 0) \
    $(usex 'shared' SOLDFLAGS="-shared") \
    || die "Failed make build"

  make \
    DESTDIR="${BUILD_DIR}/${PN1}" \
    PREFIX="${EPREFIX}/usr" \
    LIBDIR="${EPREFIX}"/$(get_libdir) \
    LIBS= \
    CC="${CC} -c" \
    LD="${CC} ${LDFLAGS}" \
    AR="${AR} crs" \
    MAKESO=$(usex 'shared' 1 0) \
    $(usex 'shared' SOLDFLAGS="-shared") \
    install || die "make install... error"

  CFLAGS="${CFLAGS} -I${BUILD_DIR}/${PN1}/${INCDIR#/}/${PN1}"
  LDFLAGS="${LDFLAGS} -L${BUILD_DIR}/${PN1}/$(get_libdir) -l${PN1#lib}"

  #############################################################################

  CC="${CC} -I${BUILD_DIR}/${PN1}/usr/include"

  append-ldflags "-s -static --static"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # Support never versions of libixp
  sed -e 's#^CFLAGS=\(.*\)$#CFLAGS+=\1 -DIXP_NEEDAPI=126#' -i Makefile

  make -j "$(nproc)" prefix="${EPREFIX%/}" || die "Failed make build"

  mkdir -pm 0755 -- "${ED}"/bin/
  mv -n ${PROG} m9play m9title -t "${ED}"/bin/ || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  strip --verbose --strip-all "bin/"${PROG}

  use 'stest' && { bin/${PROG} -help || : die "binary work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz