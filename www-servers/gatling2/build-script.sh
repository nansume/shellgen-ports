#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-07-06 12:00 UTC - last change
# Build with useflag: +static +static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="High performance web server"
HOMEPAGE="http://www.fefe.de/gatling/"
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
PN=${PN%[0-9]}; PN=${PN%-diet}
PV="0.16"
SRC_URI="
  http://www.fefe.de/${PN}/${PN}-${PV}.tar.xz
  http://www.fefe.de/libowfat/libowfat-0.33.tar.xz
  https://zlib.net/zlib-1.2.11.tar.xz
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
IUSE="+zlib +static -shared -doc (+musl) +stest +strip"
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
MKTARGET=${PN}

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
  "dev-libs/openssl3" \
  "#net-libs/mbedtls2" \
  "sys-devel/binutils9" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/libcap  # FIX: capability.h: No such file" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  mkdir -pm 0755 -- "${DIETHOME}/"
  chown ${BUILD_USER}:${BUILD_USER} "${DIETHOME}/"
  sw-user || die "Failed package build from user... error"
  exit
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  for PF in *.tar.xz; do
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 ;;
    'x86')   append-flags -m32  ;;
    'amd64') append-flags -m64  ;;
  esac
  append-ldflags -Wl,--gc-sections
  append-ldflags "-s -static --static"
  append-cflags -ffunction-sections -fdata-sections
  append-flags -Os -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc"

  #############################################################################

  use 'zlib' && {
	cd "${WORKDIR}/zlib-1.2.11/" || die "builddir: not found... error"

  ./configure \
    --prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --static \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"
  make DESTDIR="${BUILD_DIR}/zlib" install || die "make install... error"

  CFLAGS="${CFLAGS} -I${BUILD_DIR}/zlib/${INCDIR#/}"
  LDFLAGS="${LDFLAGS} -L${BUILD_DIR}/zlib/$(get_libdir) -lz"
  }

  #############################################################################

  cd "${WORKDIR}/libowfat-0.33/" || die "builddir: not found... error"

  append-flags -fomit-frame-pointer

  make headers

  make -j "$(nproc)" \
    DIET="" \
    CC="${CC}" \
    CFLAGS="-I${DIETHOME}/include -I. ${CFLAGS}" \
    DESTDIR="${BUILD_DIR}/libowfat" \
    prefix="${EPREFIX%/}" \
    LIBDIR="${EPREFIX%/}/$(get_libdir)" \
    INCLUDEDIR="${INCDIR}" \
    MAN3DIR="${DPREFIX}/share/man/man3" \
    all install \
    || die "Failed make build"

  CFLAGS="${CFLAGS} -I${BUILD_DIR}/libowfat/${INCDIR#/}/libowfat"
  CFLAGS="${CFLAGS} -I${BUILD_DIR}/libowfat/${INCDIR#/}"
  LDFLAGS="${LDFLAGS} -L${BUILD_DIR}/libowfat/$(get_libdir) -lowfat"

  #############################################################################

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

	sed -e "/^MANDIR=/d" -e "/^CFLAGS=/d" -e "/^LDFLAGS=/d" -i Makefile GNUmakefile
	sed -e '/^[[:space:]]install -d / s| $(man1dir)| $(DESTDIR)$(man1dir)|' -i Makefile GNUmakefile

  append-flags -Wno-implicit-function-declaration

  #CFLAGS="${CFLAGS} -DUSE_POLARSSL"

	rm -- Makefile

  SMB_SUPPORT="0" \
  FTP_SUPPORT="1" \
  SUPPORT_HTTPS="0" \
  make -j "$(nproc)" \
    DIET="" \
    CC="${CC}" \
    CFLAGS="${CFLAGS} -DNO_SUPPORT_HTTPS" \
    LDFLAGS="${LDFLAGS}" \
    DESTDIR="${ED}" \
    prefix="${EPREFIX%/}" \
    MANDIR="${DPREFIX}/share/man" \
    $(usex !zlib ZLIB="0") \
    ${MKTARGET} install \
    || printf %s\\n "die 'Failed make build'"

  cd "${ED}/" || die "install dir: not found... error"

  rm -v -r -- "usr/share/man/" "usr/"

  strip --verbose --strip-all "bin/"*

  use 'stest' && { bin/${PN} -h || : die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz