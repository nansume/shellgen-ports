#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-14 23:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs -upx +patch -doc -xstub -diet +musl +stest +strip +x32

export USER XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="Cross-platform library for building Telegram clients"
HOMEPAGE="https://core.telegram.org/tdlib"
LICENSE="BSL-1.0 (Boost-1.0)"
DOCS="README.md"
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="1.8.0"
PV="1.8.33"
PV="1.8.10"
PV="1.8.21"
SRC_URI="
  ftp://shellgen.mooo.com/pub/distfiles/${PN}-${PV}.tar.xz
  #https://github.com/tdlib/td/archive/master.tar.gz -> ${PN}-${PV}.tar.gz
  #https://github.com/tdlib/td/archive/v${PV}.tar.gz -> ${PN}-1.8.0.tar.gz
  http://data.gpo.zugaina.org/akater/net-libs/tdlib/files/tdlib-1.8.0-fix-runpath.patch
"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-cli -debug -doc +gcc -java -low-ram -lto -test -static-libs +shared (+musl) +stest +strip"
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
ZCOMP="unxz"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/td-${PV}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/td-master"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/tdlib"
WORKDIR=${BUILD_DIR}
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
  "dev-build/cmake" \
  "dev-libs/openssl3" \
  "dev-util/gperf" \
  "dev-util/pkgconf" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

# git: not found - required fix

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"  # only for user-build

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  inherit cmake install-functions

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}/${PN}"-1.8.0-fix-runpath.patch

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc$(usex static ' --static')"
  CXX="g++$(usex static ' --static')"

  use 'strip' && INSTALL_OPTS="install/strip"

  # from mva
  sed -r \
    -e '/install\(TARGETS/,/  INCLUDES/{s@(LIBRARY DESTINATION).*@\1 ${CMAKE_INSTALL_LIBDIR}@;s@(ARCHIVE DESTINATION).*@\1 ${CMAKE_INSTALL_LIBDIR}@;s@(RUNTIME DESTINATION).*@\1 ${CMAKE_INSTALL_BINDIR}@}' \
    -i CMakeLists.txt

  # from pg_overlay
  if use 'test'; then
    sed -e '/run_all_tests/! {/all_tests/d}' -i test/CMakeLists.txt || die
  else
    sed \
      -e '/enable_testing/d' \
      -e '/add_subdirectory.*test/d' \
      -i CMakeLists.txt || die
  fi
  # for now, tests segfault for me on glibc and musl

  mkdir -pm 0755 -- "${BUILD_DIR}/build/"
  cd "${BUILD_DIR}/build/" || die "builddir: not found... error"

  # required fix for pkgconfig/*.pc files - prefix to wrong
  # -DCMAKE_INSTALL_PREFIX=${EPREFIX%/} --> ${EPREFIX}
  cmake \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX:-/}" \
    -DCMAKE_INSTALL_LIBDIR="${EPREFIX%/}/$(get_libdir)" \
    -DCMAKE_INSTALL_INCLUDEDIR="${INCDIR}" \
    -DCMAKE_BUILD_TYPE=$(usex 'debug' Debug Release) \
    -DTD_ENABLE_LTO=$(usex 'lto' ON OFF) \
    -DTD_ENABLE_JNI=$(usex 'java' ON OFF) \
    -DTD_ENABLE_DOTNET=OFF \
    -DBUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -DCMAKE_SKIP_INSTALL_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    .. || die "Failed cmake build"

  # fix overflow memory (-j4 required over 8Gb ram memory): -j? => -j1
  #make -j "$(nproc --ignore=2)" || die "Failed make build"  # work to fine.
  make -j "$(nproc --ignore=1)" || die "Failed make build"  # testing

  # from pg_overlay
  if use 'doc'; then
    doxygen Doxyfile || die "Could not build docs with doxygen"
  fi
  # completes without errors but I don`t know if it`s sensible

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  use 'cli' && dobin "${BUILD_DIR}/build"/tg_cli
  # can't we just skip it during build?

  # from pg_overlay
  use 'doc' && HTML_DOCS="docs/html/."
  use 'doc' && einstalldocs

  cd "${ED}/" || die "install dir: not found... error"

  if use 'cli'; then
    # simple test
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
    use 'stest' && { bin/tg_cli -v || : die "binary work... error";}

    ldd "bin/tg_cli" || { use 'static' && true || die "library deps work... error";}
  fi
  # replace: -L/usr/$(get_libdir) -l:libz.so  ==>  -L/$(get_libdir) -l:libz.so
  for X in $(get_libdir)/pkgconfig/*.pc; do
    sed -e '/^Libs.private:/ s|/usr/|/|' -i ${X}
  done

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
