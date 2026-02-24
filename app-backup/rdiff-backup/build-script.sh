#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-06-01 21:00 UTC, 2026-02-14 23:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs -nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/app-backup/rdiff-backup/rdiff-backup-2.2.6.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Local/remote mirroring+incremental backup"
HOMEPAGE="https://github.com/rdiff-backup/rdiff-backup"
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
PV="2.2.6"
SRC_URI="https://files.pythonhosted.org/packages/source/r/rdiff-backup/${PN}-${PV}.tar.gz"
SRC_URI="https://github.com/rdiff-backup/rdiff-backup/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+shared -nopie -doc (+musl) +stest +strip"
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
PROG="bin/${PN}"

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
  "app-crypt/libb2  # deps python (optional)" \
  "dev-lang/python3-12" \
  "dev-libs/expat  # deps python" \
  "dev-libs/libffi  # deps python" \
  "dev-libs/popt  # deps librsync" \
  "#dev-python/py39-build  # testing" \
  "dev-python/py39-flitcore" \
  "#dev-python/py38-importlib-resources  # for <build tool>" \
  "dev-python/py39-installer" \
  "#dev-python/py38-mako  # no needed! it remove." \
  "dev-python/py39-packaging  # deps: pip3" \
  "#dev-python/py39-pyproject-hooks  # testing" \
  "dev-python/py39-pip3" \
  "dev-python/py38-pylibacl" \
  "dev-python/py38-pyxattr" \
  "dev-python/py38-pyyaml" \
  "dev-python/py39-setuptools  # for <build tool>" \
  "#dev-python/py39-setuptools-scm" \
  "#dev-python/py38-tomli" \
  "#dev-python/py39-wheel" \
  "#dev-python/py39-zipp  # for <build tool>" \
  "dev-util/pkgconf" \
  "net-libs/librsync  # ?librsync1" \
  "sys-devel/binutils9" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps: pip3" \
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
  append-flags -O2 -fno-stack-protector $(usex 'nopie' -no-pie) -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"
  HOME=${INSTALL_DIR}

  : ${PYTHON_VER:?}

  if test -x "/bin/cc"; then
    PYTHON_XLIBS="${INSTALL_DIR}/$(get_libdir)/python${PYTHON_VER}/site-packages"
    export PYTHONPATH=${PYTHON_XLIBS}
  else
    PYTHON_XLIBS="${INSTALL_DIR}/lib/python${PYTHON_VER}/site-packages"
    export PYTHONPATH=${PYTHON_XLIBS}
  fi

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  sed -e "s#share/doc/${PN}#share/doc/${PN}-${PV}#" -i setup.py || die

  # BUG[1]: asciidoctor: not found
  # BUG[1]: error: can`t copy dist/rdiff-backup.1: doesn`t exist or not a regular file
  mkdir -m 0755 -- "dist/"
  >dist/rdiff-backup.1
  >dist/rdiff-backup-delete.1
  >dist/rdiff-backup-statistics.1

  python3 -m "pip" install \
    --root "${EPREFIX:?}" \
    --target "${PYTHON_XLIBS}" \
    --no-index \
    --find-links "file:///${DISTSOURCE#/}/" \
    --no-build-isolation \
    --no-deps ${PWD} \
    ${PKGNAME} \
    || die "pip3 install... error"

  cd "${ED}/" || die "install dir: not found... error"

  mkdir -m 0755 -- usr/

  mv -v -n ${LIB_DIR}/python${PYTHON_VER}/site-packages/bin -t .
  mv -v -n ${LIB_DIR}/python${PYTHON_VER}/site-packages/share -t usr/

  if test -x "/bin/cc"; then
    mkdir -pm 0755 -- "${INSTALL_DIR}"/lib/python${PYTHON_VER}/site-packages/
    for X in "${INSTALL_DIR}"/${LIB_DIR}/python${PYTHON_VER}/site-packages/*; do
      test -n "${X##*\*}" || continue
      X="${X#$INSTALL_DIR}"
      P="${X#/$LIB_DIR/}"
      P="${P%/site-packages/*}"
      printf %s\\n "ln -s ${X} lib/${P}/site-packages/"
      ln -s ${X} "${INSTALL_DIR}"/lib/${P}/site-packages/
    done
  fi

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -v -r -- "usr/share/doc/" "usr/share/man/"
  rm -v -r -- "usr/share/bash-completion/" "usr/"

  use 'stest' && { ${PROG} --version || : die "binary work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz