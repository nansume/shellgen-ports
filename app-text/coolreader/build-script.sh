#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2024-04-21 23:00 UTC - last change
# Date: 2024-10-30 19:00 UTC - last change
# Build with useflag: +qt4 -qt5 -doc -xstub +musl +stest +strip +x32

#inherit build cmake-utils git-r3 pkg-export build-functions

export XPN PF PV WORKDIR BUILD_CHROOT PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="CoolReader - reader of eBook files (fb2,epub,htm,rtf,txt)"
HOMEPAGE="http://www.coolreader.org/"
LICENSE="GPL-2"  # review licenses (unrar - nofree license,eula)
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
XPV="3.1.2-116"  # qt4 only, BUG: no build... Failed
XPV="3.2.2-1"
PV=${XPV/-/.}  # no-posix
SRC_URI="
  https://github.com/buggins/coolreader/archive/cr${XPV}.tar.gz -> coolreader-${PV}.tar.gz
  http://alreader.com/downloads/AlReader2.Hyphen.zip
  http://shellgen.mooo.com/pub/distfiles/patch/${PN}/${PN}-01-remove-fontconfig.diff
  http://shellgen.mooo.com/pub/distfiles/patch/${PN}/${PN}-02-liberation-fnt.diff
"
USE_BUILD_ROOT='0'
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="(+musl) (-debug) +stest (-test) +strip"
IUSE="${IUSE} -rpath -doc +qt4 -qt5 -wxwidgets -hyphen -unrar -xstub"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-cr${XPV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:${DPREFIX}/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
CMAKE_PREFIX_PATH="/${LIB_DIR}/cmake"
PROG="cr3"

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
  "dev-libs/expat  # icu,freetype" \
  "dev-libs/glib-compat" \
  "dev-libs/icu-compat  # deps qt5base" \
  "dev-libs/libffi  # for glib" \
  "dev-qt/qt4" \
  "#dev-qt/qt5base  # not support in ver" \
  "dev-util/cmake" \
  "dev-util/pkgconf" \
  "media-fonts/liberation-fonts" \
  "media-libs/fontconfig" \
  "media-libs/freetype" \
  "media-libs/libpng" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps: coolreader,png" \
  "x11-base/xorg-proto" \
  "x11-libs/libice" \
  "x11-libs/libsm" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxrandr" \
  "x11-libs/libxrender" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  rm -- /usr/include/zlib.h  # no use system-zlib, therefore bundled
  sw-user || die "Failed package build from user... error"
  exit
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  use 'hyphen' && {
    mkdir -m 0755 "${PDIR%/}/${SRC_DIR}/hyphen/"
    unzip -q "AlReader2.Hyphen.zip" | tar -C "${PDIR%/}/${SRC_DIR}/hyphen/" -xkf - || exit &&
    printf %s\\n "unzip -q AlReader2.Hyphen.zip | tar -C ${PDIR%/}/${SRC_DIR}/hyphen/ -xkf -"
  }

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  #rm -r -- thirdparty/unrar/  # build... Failed

  for F in "${FILESDIR}/"*".diff"; do
    test -f "${F}" && patch -p1 -E < "${F}"
  done

  # fix for amd64
  if use 'amd64' || use 'x32'; then
    sed -e 's/unsigned int/unsigned long/g' -i crengine/src/lvdocview.cpp ||
     die "patching lvdocview.cpp for amd64 failed"
  fi

  mkdir -m 0755 -- "${BUILD_DIR}/build/"
  cd "${BUILD_DIR}/build/" || die "builddir: not found... error"

  #-DUSE_UNRAR=0  # BUG: reverse - on unrar build
  . runverb \
  cmake \
    -D CMAKE_INSTALL_PREFIX="${EPREFIX%/}/usr" \
    -D CMAKE_INSTALL_BINDIR="${EPREFIX%/}/bin" \
    -D CMAKE_INSTALL_DATADIR="${DPREFIX}/share" \
    -D CMAKE_INSTALL_DOCDIR="${DPREFIX}/share/doc" \
    -D CMAKE_INSTALL_MANDIR="${DPREFIX}/share/man" \
    -D CMAKE_BUILD_TYPE="Release" \
    -D CMAKE_CXX_STANDARD="98" \
    -D GUI=$(usex 'qt4' QT QT5) \
    -DUSE_UNRAR="0" \
    -DDOC_DATA_COMPRESSION_LEVEL="3" \
    -DDOC_BUFFER_SIZE="0x1400000" \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -D BUILD_SHARED_LIBS="OFF" \
    -Wno-dev \
    .. || die "Failed cmake build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  mv -vn usr/bin -t .

  use 'doc' || rm -r -- "usr/share/doc/" "usr/share/man/"

  # simple test
  use 'stest' && { bin/${PROG} --version || die "binary work... error";}

  ldd "bin/${PROG}" || die "library deps work... error"

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
