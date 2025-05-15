#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-11 23:00 UTC - last change
# Build with useflag: -static -static-libs +shared -system-zlib +patch -doc -xstub -diet +musl +stest +strip +x32

export USER XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

# Please bump with dev-lang/tk!

DESCRIPTION="Tool Command Language"
HOMEPAGE="http://www.tcl.tk/"
LICENSE="tcltk Spencer-99 BSD-3 ZLIB"
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="8.6.13"
SRC_URI="
  ftp://ftp.vectranet.pl/gentoo/distfiles/${PN}-core${PV}-src.tar.gz
  http://data.gpo.zugaina.org/gentoo/dev-lang/tcl/files/tcl-8.6.10-multilib.patch
  http://data.gpo.zugaina.org/gentoo/dev-lang/tcl/files/tcl-8.6.8-conf.patch
  http://data.gpo.zugaina.org/gentoo/dev-lang/tcl/files/tcl-8.6.9-include-spec.patch
  http://data.gpo.zugaina.org/gentoo/dev-lang/tcl/files/tcl-8.6.13-tclConfig-TCL_PACKAGE_PATH-braces.patch
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
IUSE="-debug +threads -system-zlib"
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
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}${PV}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}${PV}/unix"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}

SPARENT="${PDIR%/}/${SRC_DIR}/${PN}${PV}"
S=${BUILD_DIR}

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
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'system-zlib' && pkginst "sys-libs/zlib"  # system-zlib (optional) or bundled-zlib

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"  # only for user-build

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  inherit autotools flag-o-matic multilib toolchain-funcs install-functions

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"
  printf %s\\n "cd ${WORKDIR}/"

  patch -p1 -E < "${FILESDIR}"/${PN}-8.6.10-multilib.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-8.6.8-conf.patch  # Bug 125971
  patch -p1 -E < "${FILESDIR}"/${PN}-8.6.9-include-spec.patch  # Bug 731120
  patch -p1 -E < "${FILESDIR}"/${PN}-8.6.13-tclConfig-TCL_PACKAGE_PATH-braces.patch  # Bug 892029

  cd "${BUILD_DIR}/" || die "builddir: not found... error"
  printf %s\\n "cd ${BUILD_DIR}/"

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

  use 'strip' && INSTALL_OPTS="install-strip"

  # By dropping the compat directory a lot of licensing and attribution burden
  # (BSD-3, zlib,...) is lifted from the user - bundled-zlib -> system-zlib and other
  use 'system-zlib' && { find "${SPARENT}"/compat/* "${SPARENT}"/doc/try.n -delete || die;}

  : pushd "${SPARENT}" &>/dev/null || die
  : default
  : popd &>/dev/null || die

  # httpold tests require netowk
  rm -- ../tests/httpold.test ../tests/env.test ../tests/http.test || die

  sed -e '/chmod/s:555:755:g' -i Makefile.in || die
  sed -e 's:-O[2s]\?::g' -i tcl.m4 || die

  #mv configure.in configure.ac || die

  : eautoconf

  # We went ahead and deleted the whole compat/ subdir which means
  # the configure tests to detect broken versions need to pass (else
  # we'll fail to build).  This comes up when cross-compiling, but
  # might as well get a minor configure speed up normally.
  export ac_cv_func_memcmp_working="yes"
  export tcl_cv_strstr_unbroken="ok"
  export tcl_cv_strtoul_unbroken="ok"
  export tcl_cv_strtod_unbroken="ok"
  export tcl_cv_strtod_buggy="no"

  # is --prefix=${EPREFIX%/} replace with --prefix=${EPREFIX} same to <dev-lang/tcl>
  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'threads') \
    $(use_enable 'debug' symbols) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    $(use_enable 'nls') \
    $(use_enable 'rpath') \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  #short version number
  v1=${PV%.*}
  mylibdir=$(get_libdir)  # replace with LIB_DIR

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  # fix the tclConfig.sh to eliminate refs to the build directory
  # and drop unnecessary -L inclusion to default system libdir

  sed \
    -e "/^TCL_BUILD_LIB_SPEC=/s:-L${BUILD_DIR} *::g" \
    -e "/^TCL_LIB_SPEC=/s:-L${EPREFIX%/}/${mylibdir} *::g" \
    -e "/^TCL_SRC_DIR=/s:${SPARENT}:${EPREFIX%/}/${mylibdir}/tcl${v1}/include:g" \
    -e "/^TCL_BUILD_STUB_LIB_SPEC=/s:-L${BUILD_DIR} *::g" \
    -e "/^TCL_STUB_LIB_SPEC=/s:-L${EPREFIX%/}/${mylibdir} *::g" \
    -e "/^TCL_BUILD_STUB_LIB_PATH=/s:${BUILD_DIR}:${EPREFIX%/}/${mylibdir}:g" \
    -e "/^TCL_LIBW_FILE=/s:'libtcl${v1}..TCL_DBGX..so':\"libtcl${v1}\$\{TCL_DBGX\}.so\":g" \
    -i "${ED}"/${mylibdir}/tclConfig.sh || die

  # install private headers
  insinto /${mylibdir}/tcl${v1}/include/unix
  doins "${BUILD_DIR}"/*.h
  insinto /${mylibdir}/tcl${v1}/include/generic
  doins "${SPARENT}"/generic/*.h
  rm -f "${ED}"/${mylibdir}/tcl${v1}/include/generic/tcl.h || die
  rm -f "${ED}"/${mylibdir}/tcl${v1}/include/generic/tclDecls.h || die
  rm -f "${ED}"/${mylibdir}/tcl${v1}/include/generic/tclPlatDecls.h || die

  # install symlink for libraries
  ln -s libtcl${v1}.so ${mylibdir}/libtcl.so
  ln -s libtclstub${v1}.a ${mylibdir}/libtclstub.a

  ln -s tclsh${v1} bin/tclsh
  dodoc "${SPARENT}"/ChangeLog* "${SPARENT}"/README.md "${SPARENT}"/changes

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  ldd "bin/tclsh" || { use 'static' && true;}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
