#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-02-16 18:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-libs/boost/boost-1.87.0.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="Boost Libraries for C++"
HOMEPAGE="https://www.boost.org/"
LICENSE="Boost-1.0"
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
PN1="boost"
PV="1_78_0"
XPV=${PV//_/.} # no-posix
SRC_URI="
  ftp://mirrors.tera-byte.com/pub/gentoo/distfiles/${PN1}_${PV}.tar.bz2
  http://data.gpo.zugaina.org/Miezhiko/dev-libs/boost/files/${PN1}-1.71.0-context-x32.patch
  http://data.gpo.zugaina.org/Miezhiko/dev-libs/boost/files/${PN1}-1.78.0-interprocess-musl-include.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-bzip2 +context -debug -doc -icu -lzma -nls -mpi -numpy -python -stacktrace -tools +zlib -zstd"
IUSE="${IUSE} +threads +bootstrap -static -static-libs +shared (+musl) +stest +strip"
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
ZCOMP="bunzip2"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN1}_${PV}"
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
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl0" \
  "sys-libs/zlib" \
  || die "Failed install build pkg depend... error"

use 'bootstrap' || pkginst "dev-build/b2"

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
  append-cppflags -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE

  CC="gcc" CXX="g++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  use 'x32'  && patch -p1 -E < "${FILESDIR}"/${PN1}-1.71.0-context-x32.patch
  use 'musl' && patch -p1 -E < "${FILESDIR}"/${PN1}-1.78.0-interprocess-musl-include.patch
  use 'x32'  && patch -p1 -E < "${PDIR}/patches"/02-${PN1}-1.78.0-jamroot_x32.diff

  test -x "/bin/b2" || {
    # compile is the <b2> for bootstraping.
    ./bootstrap.sh \
      --prefix="/usr" \
      --exec-prefix="${EPREFIX%/}" \
      --libdir="${EPREFIX%/}/$(get_libdir)" \
      --includedir="${INCDIR}" \
      $(usex 'x32' abi=${ABI})
      link=$(usex 'shared' shared static) \
      || die "build <b2>... error"
  }
  test -x "./b2" || ln -s "/bin/b2" ./b2

  ./b2 \
    -j"$(nproc)" \
    -d+2 \
    -q \
    --prefix="${ED}/usr" \
    --exec-prefix="${ED}" \
    --libdir="${ED}/$(get_libdir)" \
    --cmakedir="${ED}/$(get_libdir)/cmake" \
    --includedir="${ED}/${INCDIR#/}" \
    --stagedir="./stage" \
    --build-type="minimal" \
    --build-dir="build/" \
    --layout="system" \
    --without-python \
    $(usex !icu '--disable-icu boost.locale.icu=off') \
    $(usex !mpi --without-mpi) \
    $(usex !nls --without-locale) \
    $(usex !context '--without-context --without-coroutine --without-fiber') \
    $(usex !stacktrace --without-stacktrace) \
    $(usex 'x32' abi=${ABI}) \
    toolset=${CC} \
    variant=$(usex 'debug' debug release) \
    threading=$(usex 'threads' multi single) \
    link=$(usex 'static-libs' shared,static shared) \
    pch=off \
    install \
    || die "./b2 build and install... Failed"

  cd "${ED}/" || die "install dir: not found... error"

  use 'static-libs' || rm -- "$(get_libdir)/"/lib${PN1}_*.a

  use 'strip' && {
    strip --verbose --strip-all "$(get_libdir)/"/lib${PN1}_*.so.${XPV}
    use 'static-libs' && strip --strip-unneeded "$(get_libdir)/"/lib${PN1}_*.a
  }

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${XPV} pkg-create-cgz
