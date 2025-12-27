#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-18 14:00 UTC - last change
# Build with useflag: +shared +ipv6 +ssl -doc +musl +stest +x32

export USER XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="An interpreted, interactive, object-oriented programming language"
HOMEPAGE="https://www.python.org/"
LICENSE="PSF-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
XPN="Python"
XPN="${6:-${XPN:?}}"
PV="3.6.5"
PYVER=${PV%.*}
PATCHSET="python-gentoo-patches-3.6.4.tar.xz"
SRC_URI="
  ftp://ftp.vectranet.pl/gentoo/distfiles/Python-${PV}.tar.xz
  https://dev.gentoo.org/~floppym/python/${PATCHSET}
  ftp://shellgen.mooo.com/pub/distfiles/python-3.5-distutils-OO-build.patch
  ftp://shellgen.mooo.com/pub/distfiles/3.6.5-disable-nis.patch
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
IUSE="+shared (+musl) -man -doc +ipv6 +stest -test +strip -bluetooth"
IUSE="${IUSE} -build -examples +gdbm -hardened +ncurses +readline"
IUSE="${IUSE} +sqlite +ssl -libressl +threads -tk -wininst +xml -pgo"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
XPWD=${5:-$XPWD}
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
PKGNAME=${PN%[23]}
ZCOMP="unxz"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${XPN}-${PV}"
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
  "dev-lang/python3" \
  "dev-libs/expat" \
  "dev-libs/libffi" \
  "#dev-libs/mpdecimal  # no-bundled, no-build" \
  "dev-libs/openssl-compat" \
  "dev-util/pkgconf" \
  "sys-apps/findutils" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "#sys-devel/patch" \
  "sys-kernel/linux-headers" \
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
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  for PF in ${PATCHSET} ${PF}; do
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-flags -O2 -fno-stack-protector -g0 -march=$(arch | sed 's/_/-/')
  append-flags -fwrapv  # gcc4 or later version.

  use 'bluetooth' || export ac_cv_header_bluetooth_bluetooth_h="no"
  use 'ssl'       || export PYTHON_DISABLE_SSL="1"

  export PYTHON_DISABLE_MODULES=
  use 'gdbm'     || PYTHON_DISABLE_MODULES=" gdbm"
  use 'ncurses'  || PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} _curses _curses_panel"
  use 'readline' || PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} readline"
  use 'sqlite'   || PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} _sqlite3"
  use 'tk'       || PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} _tkinter"
  use 'xml'      || PYTHON_DISABLE_MODULES="${PYTHON_DISABLE_MODULES} _elementtree pyexpat"

  export CC="cc" CXX="c++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  for F in "${WORKDIR}"/patches "${FILESDIR}"/*.patch; do
    test -f "${F}" || continue
    printf %s\\n "patch -p1 -E < ${F##*/}"
    patch -p1 -E < "${F}"
  done

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  test -e 'Lib/test/libregrtest/runtest.py' && rm -- 'Lib/test/libregrtest/runtest.py'

  # force system libs
  rm -r -- Modules/expat Modules/_ctypes/darwin* Modules/_ctypes/libffi*

  sed -i -e "s:@@GENTOO_LIBDIR@@:$(get_libdir):g" \
    Lib/distutils/command/install.py \
    Lib/distutils/sysconfig.py \
    Lib/site.py \
    Lib/sysconfig.py \
    Lib/test/test_site.py \
    Makefile.pre.in \
    Modules/Setup.dist \
    Modules/getpath.c \
    configure.ac \
    setup.py || die "sed failed to replace @@GENTOO_LIBDIR@@"

  . runverb \
  ./configure \
    CC="${CC}" \
    CXX="${CXX}" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --mandir="${DPREFIX}/share/man" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --with-libc= \
    --with-computed-gotos \
    --with-dbmliborder="gdbm" \
    $(use_enable 'ipv6') \
    $(use_with 'threads') \
    --without-ensurepip \
    --enable-optimizations \
    --enable-loadable-sqlite-extensions \
    --with-system-expat \
    --with-system-ffi \
    --without-system-libmpdec \
    --without-lto \
    $(use_enable 'shared') \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    || die "configure... error"

  make -j "$(nproc)" CPPFLAGS= CFLAGS= LDFLAGS= || die "Failed make build"

  . runverb \
  make \
    DESTDIR="${ED}" \
    PREFIX="${SPREFIX%/}/${INSTALL_DIR#/}" \
    install \
    || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  sed \
    -e "s/\(CONFIGURE_LDFLAGS=\).*/\1/" \
    -e "s/\(PY_LDFLAGS=\).*/\1/" \
    -i "lib/python${PYVER}/config-${PYVER}"*/Makefile || : die "sed failed"

  test -e "bin/python3" && ln -vsf python3 "bin/python"
  # python build config - header
  mv -vn include/python${PYVER}m/pyconfig.h "${DPREFIX#/}/include/python${PYVER}m/"
  # fix: not find platform dependent libraries <exec_prefix>
  ln -vsf ../../$(get_libdir)/python${PYVER}/lib-dynload "lib/python${PYVER}/"

  rm -vr -- include/ lib/python*/config-*/*.o usr/share/
  # Remove static library
  rm -vf -- lib/libpython*.a $(get_libdir)/libpython*.a || : die

  bin/${PN} --version || : die "binary work... error"

  ldd "bin/${PN}" || : die "ldd test... error"

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
