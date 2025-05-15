#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-02-17 15:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-libs/boost/boost-1.87.0.ebuild
# http://data.gpo.zugaina.org/gentoo/dev-build/b2/b2-5.2.1.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CXX

DESCRIPTION="A system for large project software construction, simple to use and powerful"
HOMEPAGE="https://www.bfgroup.xyz/b2/"
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
PV="5.2.1"
SRC_URI="
  https://github.com/bfgroup/b2/archive/refs/tags/${PV}.tar.gz -> ${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/dev-build/${PN}/files/${PN}-4.9.2-disable_python_rpath.patch
  http://data.gpo.zugaina.org/gentoo/dev-build/${PN}/files/${PN}-4.9.2-add-none-feature-options.patch
  http://data.gpo.zugaina.org/gentoo/dev-build/${PN}/files/${PN}-4.9.2-no-implicit-march-flags.patch
  http://data.gpo.zugaina.org/gentoo/dev-build/${PN}/files/site-config.jam
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-examples +static -shared -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}/src"
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
  "sys-libs/musl0" \
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

  inherit flag-o-matic edo install-functions

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
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
  # need to enable LFS explicitly for 64-bit offsets on 32-bit hosts (#761100)
  append-cppflags -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE
  #append-lfs-flags  # BUG: not found

  CXX="g++$(usex static ' -static --static')"

  export B2_DONT_EMBED_MANIFEST=1

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/${PN}-4.9.2-disable_python_rpath.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-4.9.2-add-none-feature-options.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-4.9.2-no-implicit-march-flags.patch

  cd "${BUILD_DIR}/engine/"

  edo ${CONFIG_SHELL:-/bin/sh} ./build.sh cxx \
    --cxx="${CXX}" \
    --cxxflags="-pthread ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    -d+2 \
    --without-python \
    || die "Failed make build"

  cd "${BUILD_DIR}/"

  mkdir -m 0755 -- "${ED}/bin/"

  mv -vn engine/${PN} -t ${ED}/bin/

  insinto /usr/share/${PN}/src
  doins -r "${FILESDIR}/site-config.jam" \
   build-system.jam ../example/user-config.jam \
   build contrib options tools util

  dodoc ../notes/changes.txt ../notes/release_procedure.txt
  dodoc ../notes/build_dir_option.txt ../notes/relative_source_paths.txt

  if use 'examples'; then
    docinto examples
    dodoc -r ../example/.
    docompress -x /usr/share/doc/${PN}-${PV}/examples
  fi

  cd "${ED}/" || die "install dir: not found... error"

  find "usr/share/${PN}/src/" -iname '*.py' -delete || die

  use 'strip' && strip --verbose --strip-all bin/${PN}

  use 'stest' && { bin/${PN} --version || : die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
