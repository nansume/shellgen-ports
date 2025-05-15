#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-11 13:00 UTC - last change
# Build with useflag: +static +static-libs +shared -lfs -upx +patch -doc -xstub -diet +musl +stest +strip +x32

export USER XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX AR

DESCRIPTION="Adds a lot of image formats to Tcl/Tk"
HOMEPAGE="http://tkimg.sourceforge.net/"
LICENSE="BSD"
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="1.4.16"
SRC_URI="
  https://downloads.sourceforge.net/${PN}/${PN}/${PV%.*}/${PN}%20${PV}/Img-${PV}-Source.tar.gz \
  -> ${PN}-${PV}-Source.tar.gz
  https://dev.gentoo.org/~tupone/distfiles/${PN}-1.4.14-patchset-1.tar.gz
  http://data.gpo.zugaina.org/gentoo/dev-tcltk/tkimg/files/tkimg-1.4.15-gcc11.patch
"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-doc -test -static-libs +shared (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/Img-${PV}"
WORKDIR=${BUILD_DIR}
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
  "dev-lang/tcl" \
  "dev-lang/tk" \
  "dev-libs/expat  # for xft?" \
  "dev-tcltk/tcllib" \
  "media-libs/freetype  # for xft?" \
  "media-libs/fontconfig  # for xft?" \
  "#media-libs/glu  # required OpenGL?" \
  "#media-libs/libjpeg-turbo" \
  "media-libs/libpng" \
  "#media-libs/tiff" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  "x11-base/xorg-proto" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb  # required?" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxft  # optional or --disable-xft" \
  "x11-libs/libxrender  # for xft (optional)" \
  "x11-libs/libxscrnsaver  # optional" \
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

  inherit autotools edos2unix prefix toolchain-funcs install-functions

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  ${ZCOMP} -dc "${PN}-1.4.14-patchset-1.tar.gz" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PN}-1.4.14-patchset-1.tar.gz | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

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

  CC="gcc$(usex static ' --static')"
  CXX="g++$(usex static ' --static')"
  AR="ar"

  edos2unix \
    libjpeg/jpegtclDecls.h \
    zlib/zlibtclDecls.h \
    libpng/pngtclDecls.h \
    tiff/tiffZip.c \
    tiff/tiffPixar.c \
    libtiff/tifftclDecls.h

  # libtiff/jpeg unbundle is problematic
  rm -- ../patchset-1/tkimg-1.4.12-tiff.patch || die
  rm -- ../patchset-1/tkimg-1.4.10-jpeg.patch || die

  #rm -- ../patchset-1/tkimg-1.4.12-png.patch || die
  #rm -- ../patchset-1/tkimg-1.4.12-zlib.patch || die

  for F in "../patchset-1/"*".patch"; do
    test -f "${F}" && patch -p1 -E < "${F}"
  done
  patch -p1 -E < "${FILESDIR}"/${PN}-1.4.15-gcc11.patch

  printf %s\\n "unknown" > manifest.uuid || die

  find compat/libtiff/config -name ltmain.sh -delete || die
  sed -e 's:"--with-CC=$TIFFCC"::' -i libtiff/configure.ac || die

  #eautoreconf
  #for dir in zlib libpng libtiff libjpeg base bmp gif ico jpeg pcx pixmap png\
  #  ppm ps sgi sun tga tiff window xbm xpm dted raw flir compat/libtiff ; do
  #  (cd ${dir}; AT_NOELIBTOOLIZE=yes eautoreconf)
  #done

  eprefixify */*.h

  ./configure \
    --prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'shared') \
    $(use_enable 'rpath') \
    || die "configure... error"

  sed -e "/PACKAGE_/d" -i libtiff/libtiff/tif_config.h || die

  make -j "$(nproc)" AR="${AR}" || die "Failed make build"

  make DESTDIR="${ED}" INSTALL_ROOT="${ED}" install || : die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  if use 'static-libs'; then
    strip --strip-unneeded "$(get_libdir)/"lib*.a
  else
    find "${ED}"/$(get_libdir)/ -type f -name "*\.a" -delete || die
  fi

  # Make library links
  for l in "${ED}"/lib*/Img*/*tcl*.so; do
    bl=$(basename ${l})
    dosym Img${PV}/${bl} /$(get_libdir)/${bl}
  done

  dodoc ChangeLog README Reorganization.Notes.txt changes ANNOUNCE

  if use 'doc'; then
    docompress -x usr/share/doc/${PN}-${PV}/demo.tcl
    dodoc demo.tcl
    docinto html
    dodoc -r doc/*
  fi

  strip --verbose --strip-all "$(get_libdir)/"lib*.so

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
