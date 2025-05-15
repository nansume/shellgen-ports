#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-05-08 13:00 UTC - last change
# Build with useflag: +static +static-libs -shared -lfs +nopie +patch -doc -xstub +diet (+musl) +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sys-libs/libixp/libixp-0.5_p20110208-r3.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="A stand-alone client/server 9P library including ixpc client"
HOMEPAGE="https://libs.suckless.org/deprecated/libixp"
LICENSE="MIT"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PV="0.5_p20110208"
XPV="0.5p20110208"
SRC_URI="
  rsync://mirror.bytemark.co.uk/gentoo/distfiles/*/${PN}-${PV}.tar.xz
  #mirror://gentoo/${PN}-${PV}.tar.xz
  http://data.gpo.zugaina.org/gentoo/sys-libs/libixp/files/${PN}-${PV}-gentoo.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static +static-libs (-shared) -doc (+diet) +strip"
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
ZCOMP="unxz"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
PROG="ixpc"

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
  "dev-libs/dietlibc" \
  "net-misc/rsync  # for (mirror://) <mirror-fetch>" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
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
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -Os
  append-ldflags -Wl,--gc-sections
  append-cflags -ffunction-sections -fdata-sections
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="diet -Os gcc -nostdinc" AR="ar"
  PATH="${PATH:+${PATH}:}/opt/diet/bin"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-gentoo.patch

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
    DESTDIR="${ED}" \
    PREFIX="${EPREFIX}/usr" \
    LIBDIR="${EPREFIX}"/$(get_libdir) \
    LIBS= \
    CC="${CC} -c" \
    LD="${CC} ${LDFLAGS}" \
    AR="${AR} crs" \
    MAKESO=$(usex 'shared' 1 0) \
    $(usex 'shared' SOLDFLAGS="-shared") \
    install || die "make install... error"

  [ -x "lib/libixp.so" ] && lib/libixp.so
  [ -x "lib/libixp_pthread.so" ] && lib/libixp_pthread.so

  cd "${ED}/" || die "install dir: not found... error"

  test -d "usr/bin" && mv -v -n usr/bin -t .

  rm -r -- "usr/share/man/" "usr/share/"

  strip --verbose --strip-all "bin/"${PROG}
  [ -x "$(get_libdir)/${PN}.so" ] && strip --verbose --strip-all "$(get_libdir)/"${PN}*.so
  strip --strip-unneeded "$(get_libdir)/"${PN}*.a

  use 'stest' && { bin/${PROG} -v || die "binary work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz