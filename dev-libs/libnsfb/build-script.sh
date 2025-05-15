#!/bin/sh
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-11-26 13:00 UTC - last change

NL="$(printf '\n\t')"; NL=${NL%?} XPWD=${XPWD:=$PWD} XPN=${PN} PKG_DIR='/pkg' LC_ALL='C'

USER=${USER:-root}
USE_BUILD_ROOT='0'
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=${PWD}
LIBDIR=${LIBDIR:-/libx32}
DPREFIX='/usr'
INCDIR="${DPREFIX}/include"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
INSTALL_OPTS='install'
MAKEFLAGS='-j4 V=0'
CFLAGS='-O2 -msse2 -fno-stack-protector -g0'
CPPFLAGS='-O2 -msse2 -fno-stack-protector -g0'
CXXFLAGS='-O2 -msse2 -fno-stack-protector -g0'
FCFLAGS='-O2 -msse2 -fno-stack-protector -g0'
FFLAGS='-O2 -msse2 -fno-stack-protector -g0'
HOSTNAME=$(hostname)
#CPU_NUM=$(cpucore-num)
BUILD_USER='tools'
SRC_DIR='build'
IONICE_COMM='nice -n 19'
XLDFLAGS=

export USER BUILDLIST XPN PF PV LIBDIR WORKDIR PKGNAME DPREFIX PKG_CONFIG_LIBDIR PKG_CONFIG_PATH
export LC_ALL BUILD_USER SRC_DIR CFLAGS CPPFLAGS CXXFLAGS FCFLAGS FFLAGS

if test "X${USER}" != 'Xroot'; then
  ABI_BUILD=${1:?} LIBDIR=${2:?} LIB_DIR=${3:?} PDIR=${4:?} XPWD=${5:?} XPN=${6:?}
  BUILD_CHROOT=${7:?} _ENV=${8} USE_BUILD_ROOT=${9} BUILDLIST=${10} CATEGORY=${11:?} PN=${12:?}
  PWD=${PWD%/}
  mksrc-prepare
elif test "${BUILD_CHROOT:=0}" -eq '0'; then
  PATH="${PATH:+${PATH}:}${PDIR}/misc.d:${PDIR}/etools.d"
elif test "${BUILD_CHROOT:=0}" -ne '0'; then
  PATH="$(xpath):${PDIR%/}/misc.d:${PDIR%/}/etools.d"
  printf %s\\n "PATH='${PATH}'" "PDIR='${PDIR}'"
fi

#BUILDLIST=$(buildlist)

. "${PDIR%/}/etools.d/"pre-env || exit

test "x${SN}" != "x${SN%%_*}" && SN="${SN%%_*}-${SN#*_}"

PF=$(pfname 'src_uri.lst')
PV=$(pkgver)
PKGNAME=$(pkgname)
ZCOMP=$(zcomp-as "${PF}")

printf %s\\n "BUILDLIST='${BUILDLIST}'" "PV='${PV}'" "PKGNAME='${PKGNAME}'"

chroot-build || exit

#. ${PDIR%/}/etools.d/"pkg-tools-env
. "${PDIR%/}/etools.d/"sh-profile-tools
. "${PDIR%/}/etools.d/"pre-env-chroot

WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"

instdeps-spkg-dep || exit
build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

no-ldconfig
netuser-fetch || exit
sw-user || exit

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  :
elif test "X${USER}" != 'Xroot'; then
  #17-prefix_cmake.sh
  #17-python.sh
  : drop-python

  . "${PDIR%/}/etools.d/"gen-variables

  cd "${DISTSOURCE}/" || exit

  test -d "${WORKDIR}" && rm -rf -- "${WORKDIR}/"
  emptydir "${INSTALL_DIR}" || rm -r -- "${INSTALL_DIR}/"*

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || exit

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  #use 'static' && export CC='gcc -static --static'

  src-patch "${DISTSOURCE}/${PN}-0.1.0-autodetect.patch"

  printf %s\\n "MAKEFLAGS='${MAKEFLAGS}'"
  printf %s\\n "CC='${CC}'" "CXX='${CXX}'" "CPP='${CPP}'" "LIBTOOL='${LIBTOOL}'"
  printf %s\\n "CFLAGS='${CFLAGS}'" "CPPFLAGS='${CPPFLAGS}'" "CXXFLAGS='${CXXFLAGS}'"
  printf %s\\n "FCFLAGS='${FCFLAGS}'" "FFLAGS='${FFLAGS}'" "LDFLAGS='${LDFLAGS}'"

  . runverb \
  make \
  	DESTDIR="${INSTALL_DIR}" \
    PREFIX="${SPREFIX%/}" \
    LIBDIR="${LIB_DIR}" \
    INCLUDEDIR="${INCDIR#/}" \
    I="${INCDIR}" \
    NSSHARED="${DPREFIX}/share/netsurf-buildsystem" \
    COMPONENT_TYPE="lib-shared" \
    WITH_VNC=$(usex 'vnc') \
    WITH_SDL=$(usex 'sdl') \
    WITH_XCB=$(usex 'x') \
    WITH_WLD=$(usex 'wayland') \
    all install || exit

  cd "${INSTALL_DIR}/" || exit

  post-inst-perm

  RMLIST="$(pkg-rmlist)" pkg-rm

  post-rm
  pkg-rm-empty
  use 'strip' && pkg-strip
  use 'upx' && upx --best "bin/${PN}"
  pre-perm
  exit
fi

cd "${INSTALL_DIR}/" || exit

pkg-perm

INST_ABI="$(test-native-abi)" pkg-create-cgz
