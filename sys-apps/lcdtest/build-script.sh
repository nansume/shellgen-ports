#!/bin/sh
# Copyright (C) 2024-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-30 14:00 UTC - last change
# Date: 2024-10-22 19:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="Displays test patterns to spot dead/hot pixels on LCD screens"
HOMEPAGE="http://www.brouhaha.com/~eric/software/lcdtest/"
LICENSE="GPL-3"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="1.18"
SRC_URI="
  http://www.brouhaha.com/~eric/software/lcdtest/download/lcdtest-1.18.tar.gz
  http://shellgen.mooo.com/pub/distfiles/patch/lcdtest/1.18-build-system.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-static +shared -doc (+musl) +stest +strip"
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
  "dev-build/scons2" \
  "dev-lang/python2" \
  "dev-lang/swig" \
  "dev-libs/expat  # for python" \
  "dev-libs/libffi  # for python" \
  "dev-libs/openssl-compat  # for python" \
  "media-fonts/liberation-fonts" \
  "media-libs/alsa-lib" \
  "media-libs/freetype" \
  "media-libs/libjpeg-turbo3" \
  "media-libs/libpng" \
  "media-libs/libwebp" \
  "media-libs/sdl  # libsdl[X,video]" \
  "media-libs/sdl-image" \
  "media-libs/sdl-ttf" \
  "media-libs/tiff" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # for libpng,setuptools" \
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

  . "${PDIR%/}/etools.d/"epython
  inherit scons-utils eutils toolchain-funcs gnome2-utils

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  if use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-ldflags "-s -static --static"
    #append-ldflags -lfreetype
    append-cflags -ffunction-sections -fdata-sections -lfreetype
    #export LIBS="-lSDL -lSDL_image -lSDL_ttf -lfreetype"
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}/${PV}-build-system.patch"

  sed -e "s|/usr/share/fonts/liberation/|/usr/share/fonts/liberation-fonts/|" -i src/lcdtest.c || die

  scons CC="${CC}" ENABLE_NLS=$(usex 'nls') || die "Failed make build"

  scons \
    --buildroot="${ED}" \
    --prefix="${EPREFIX%/}/usr" \
    --bindir="${EPREFIX%/}/bin" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    install \
    || die "make install... error"

  use 'doc' && dodoc README

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -r -- "usr/share/man/"

  strip --verbose --strip-all "bin/${PN}"

  use 'stest' && { bin/${PN} --version || : die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz