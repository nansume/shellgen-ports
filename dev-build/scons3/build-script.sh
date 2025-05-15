#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-04-23 21:00 UTC - last change
# Build with useflag: -static -static-libs -shared -lfs -nopie -patch -doc -xstub -diet +musl +stest -strip +noarch

# https://www.linuxfromscratch.org/blfs/view/9.1/general/scons.html
# http://data.gpo.zugaina.org/didos/dev-util/scons/scons-3.1.2-r3.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

DESCRIPTION="Extensible Python-based build utility"
HOMEPAGE="https://www.scons.org/"
LICENSE="MIT"
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
PV="3.1.2"
SRC_URI="https://downloads.sourceforge.net/scons/scons-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-doc (+musl) +stest"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${XPN%[0-9]}-${PV}"
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
  "dev-lang/python38" \
  "dev-libs/expat" \
  "dev-libs/libffi" \
  "dev-python/py38-setuptools" \
  "sys-devel/make" \
  "sys-libs/musl" \
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

  HOME=${ED}

  : ${PYTHONPATH:?} ${PYTHON:?} ${PYTHONPYCACHEPREFIX:?} ${PYTHON_VER:?}
  : ${PYTHON_EXEC_PREFIX:?} ${PYTHON_PREFIX:?} ${PYTHONHOME:?}

  # new behavior install for python3 [3.6]
  PYTHON_XLIBS="${ED}/lib/python${PYTHON_VER}/site-packages"  # ?python3.6

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  test -x "/bin/python3.8" && PYTHON_XLIBS=${ED}  # testing 2024.10.05 - ?python3.

  # 3rd party packages - installed here = <site-packages> dir
  if test -x "/bin/cc"; then
    PYTHON_XLIBS="${ED}/$(get_libdir)/python${PYTHON_VER}/site-packages"
  else
    PYTHON_XLIBS="${ED}/lib/python${PYTHON_VER}/site-packages"
  fi

  . runverb \
  python "setup.py" install \
    --root ${EPREFIX} \
    --prefix ${ED} \
    --install-lib ${PYTHON_XLIBS} \
    --install-data="${ED}/usr/share" \
    || die "make install... error"

  cd "${BUILD_DIR}/"

  cd "${ED}/" || die "install dir: not found... error"

  rm -r -- bin/scons*.bat usr/share/man/ usr/

  use 'stest' && { bin/${PN} --version || die "binary work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz