#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-04-05 16:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/app-text/doxygen/doxygen-1.13.2.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="Documentation system for most programming languages"
HOMEPAGE="https://www.doxygen.nl/"
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
PN=${PN%[0-9]}
PV="1.13.2"
SLOT="2"
SRC_URI="
  https://doxygen.nl/files/${PN}-${PV}.src.tar.gz
  http://data.gpo.zugaina.org/gentoo/app-text/${PN}/files/${PN}-1.9.4-link_with_pthread.patch
  http://data.gpo.zugaina.org/gentoo/app-text/${PN}/files/${PN}-1.9.8-suppress-unused-option-libcxx.patch
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
IUSE="-clang -debug -doc +dot -doxysearch -gui -test +static -shared -man (+musl) +stest +strip"
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
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
CMAKE_PREFIX_PATH="/${LIB_DIR}/cmake"

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
  "app-text/ghostscript-gpl" \
  "dev-db/sqlite3" \
  "dev-lang/perl" \
  "dev-lang/python38" \
  "dev-libs/expat  # deps python3" \
  "#dev-libs/libfmt  # not found" \
  "#dev-libs/spdlog" \
  "#dev-libs/xapian  # buildopts: <doxysearch>" \
  "#dev-util/byacc  # alternative a bison" \
  "dev-util/cmake" \
  "dev-util/pkgconf" \
  "media-gfx/graphviz  # required: graphviz[dot]" \
  "media-libs/libpng" \
  "sys-devel/binutils" \
  "sys-devel/bison" \
  "sys-devel/gcc9" \
  "sys-devel/flex" \
  "#sys-devel/lex  # alternative a flex" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "#sys-devel/patch  # for patch with fuzz and offset." \
  "sys-libs/musl0" \
  "sys-libs/zlib  # deps libpng" \
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
    append-cflags -ffunction-sections -fdata-sections
    append-ldflags "-s -static --static"
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}/${PN}-1.9.4-link_with_pthread.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-1.9.8-suppress-unused-option-libcxx.patch"

  # Call dot with -Teps instead of -Tps for EPS generation - bug #282150
  sed -e '/addJob("ps"/ s/"ps"/"eps"/g' -i src/dot.cpp || die

  # fix pdf doc
  sed -i.orig -e "s:g_kowal:g kowal:" doc/maintainers.txt || die

  cmake -B build -G "Unix Makefiles" \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}/usr" \
    -DCMAKE_INSTALL_BINDIR="${EPREFIX%/}/bin" \
    -DCMAKE_INSTALL_LIBDIR="${EPREFIX%/}/$(get_libdir)" \
    -DCMAKE_INSTALL_DATAROOTDIR="${DPREFIX}/share" \
    -DCMAKE_INSTALL_DOCDIR="${DPREFIX}/share/doc" \
    -DCMAKE_INSTALL_MANDIR="${DPREFIX}/share/man" \
    -DCMAKE_BUILD_TYPE="Release" \
    -Duse_libclang=$(usex 'clang') \
    -Duse_libc++=OFF \
    -Dbuild_doc=$(usex 'doc') \
    -Dbuild_search=$(usex 'doxysearch') \
    -Dbuild_wizard=$(usex 'gui') \
    -Dforce_qt=Qt5 \
    -Duse_sys_spdlog=OFF \
    -Duse_sys_sqlite3=OFF \
    -DGIT_EXECUTABLE="false" \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  DESTDIR="${ED}" cmake --build build --target ${INSTALL_OPTS} -j "$(nproc)" || die "make install... error"

  use 'gui' && doman doc/doxywizard.1
  use 'doxysearch' && {
   doman doc/doxyindexer.1
   doman doc/doxysearch.1
  }

  cd "${ED}/" || die "install dir: not found... error"

  test -d "usr/bin" && mv -v -n usr/bin -t .

  use 'man' || rm -r -- usr/share/man/ usr/

  use 'stest' && { bin/${PN} --version || die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz