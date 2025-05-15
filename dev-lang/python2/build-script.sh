#!/bin/sh
# Copyright (C) 2024-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-04-16 13:00 UTC - last change
# Build with useflag: +shared +ipv6 +ssl -doc +musl +stest +x32

#inherit build python2 pkg-export

export XPN PF PV WORKDIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="An interpreted, interactive, object-oriented programming language"
HOMEPAGE="https://www.python.org/"
LICENSE="PSF-2"
NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:-$PWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
XPN="Python"
XPN="${6:-${XPN:?}}"
PV="2.7.14"
PYVER=${PV%.*}
SRC_URI="ftp://ftp.vectranet.pl/gentoo/distfiles/Python-${PV}.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="linux"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+shared (+musl) +ipv6 +libffi -xstub +stest -test +strip"
IUSE="${IUSE} -man -doc -bluetooth -build -examples -gdbm -hardened"
IUSE="${IUSE} -ncurses -readline +sqlite +ssl +threads -tk -wininst +xml -pgo"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
XPWD=${5:-$XPWD}
P="${P:-${XPWD##*/}}"
SN=${P}
PN="${PN:-${P%%_*}}"
PN=${12:-$PN}
PORTS_DIR=${PWD%/$P}
DISTDIR="/usr/distfiles"
DISTSOURCE="${PDIR%/}/sources"
FILESDIR=${DISTSOURCE}
INSTALL_DIR="${PDIR%/}/install"
ED=${INSTALL_DIR}
SDIR="${PDIR%/}/${SRC_DIR}"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
PKGNAME=${PN%[23]}
ZCOMP="unxz"
WORKDIR="${PDIR%/}/${SRC_DIR}/${XPN}-${PV}"
S="${PDIR%/}/${SRC_DIR}/${XPN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
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
  "#app-alternatives/libbz2" \
  "app-arch/bzip2" \
  "app-arch/xz  # required? testing" \
  "dev-db/bdb5" \
  "dev-db/sqlite" \
  "dev-lang/python2" \
  "dev-libs/expat  # 2025.04.23 - add testing" \
  "dev-libs/libffi  # bundled no compat x32 asm" \
  "dev-libs/openssl-compat" \
  "dev-util/pkgconf" \
  "sys-apps/file" \
  "sys-apps/findutils" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "#sys-devel/patch" \
  "sys-kernel/linux-headers-musl  # pre: linux-headers" \
  "sys-libs/gdbm0  # gdbm[berkdb]" \
  "sys-libs/musl" \
  "sys-libs/ncurses  # optional" \
  "sys-libs/readline  # optional" \
  "sys-libs/zlib" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then
  HOME="/install"

  renice -n '19' -u ${USER}

  . "${PDIR%/}/etools.d/"epython

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  #test -e 'Lib/test/libregrtest/runtest.py' && rm -- 'Lib/test/libregrtest/runtest.py'

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-flags -O2 -fno-stack-protector -g0 -march=$(arch | sed 's/_/-/')
  append-flags -fwrapv  # 2025.04.23 testing

  # force system libs
  rm -r -- Modules/_ctypes/darwin* Modules/_ctypes/libffi*

  use 'bluetooth' || export ac_cv_header_bluetooth_bluetooth_h="no"
  use 'ssl'       || export PYTHON_DISABLE_SSL="1"

  IFS=${NL}

  . runverb \
  ./configure \
    CC="gcc" \
    CXX="g++" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --mandir="${DPREFIX}/share/man" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --without-ensurepip \
    --enable-optimizations \
    --with-system-expat \
    $(use_with 'libffi' system-ffi) \
    --without-lto \
    $(use_enable 'shared') \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    || die "configure... error"

  make -j "$(nproc --ignore=0)" || die "Failed make build"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  . runverb \
  make \
    DESTDIR="${ED}" \
    PREFIX="${SPREFIX%/}/${INSTALL_DIR#/}" \
    install \
    || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  test -e "bin/python2" && ln -vsf python2 "bin/python"
  # fix: not find platform dependent libraries <exec_prefix>
  ln -vsf ../../$(get_libdir)/python${PYVER}/lib-dynload "lib/python${PYVER}/"

  rm -r -- include/ usr/share/
  # Remove static library
  rm -f -- $(get_libdir)/libpython*.a || die

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${INSTALL_DIR}/$(get_libdir)"

  use 'stest' && { bin/${PN} --version || die "binary work... error";}

  ldd "bin/${PN}" || die "ldd test... error"

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
