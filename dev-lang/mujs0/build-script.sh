#!/bin/sh
# Copyright (C) 2021-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-11-11 18:00 UTC - last change

NL="$(printf '\n\t')"; NL=${NL%?} XPWD=${XPWD:=$PWD} XPN=${PN} PKG_DIR='/pkg' LC_ALL='C'

USER=${USER:-root}
USE_BUILD_ROOT='0'
BUILD_CHROOT=${BUILD_CHROOT:-0}
LIBDIR=${LIBDIR:-/libx32}
DPREFIX='/usr'
INCDIR="${DPREFIX}/include"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
INSTALL_OPTS='install'
ZCOMP='unxz'  #gunzip

export USER BUILDLIST XPN PF PV LIBDIR WORKDIR PKGNAME DPREFIX PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

if test "X${USER}" != 'Xroot'; then
  ABI_BUILD=${1:?} LIBDIR=${2:?} LIB_DIR=${3:?} PDIR=${4:?} XPWD=${5:?} XPN=${6:?}
  BUILD_CHROOT=${7:?} _ENV=${8} USE_BUILD_ROOT=${9} BUILDLIST=${10} CATEGORY=${11:?} PN=${12:?}
  PWD=${PWD%/}
  mksrc-prepare
elif test "${BUILD_CHROOT:=0}" -eq '0'; then
  PDIR=${PWD}
  PATH="${PATH:+${PATH}:}${PDIR}/misc.d:${PDIR}/etools.d"
elif test "${BUILD_CHROOT:=0}" -ne '0'; then
  PDIR=${PWD}
  PATH="$(xpath):${PDIR%/}/misc.d:${PDIR%/}/etools.d"
  printf %s\\n "PATH='${PATH}'" "PDIR='${PDIR}'"
fi

#BUILDLIST=$(buildlist)

. "${PDIR%/}/etools.d/"pre-env || exit

test "x${SN}" != "x${SN%%_*}" && SN="${SN%%_*}-${SN#*_}"

read -r PF < 'src_uri.lst'
PF=${PF##*[/ ]}
PV=$(pkgver)
PKGNAME=$(pkgname)

printf %s\\n "BUILDLIST='${BUILDLIST}'" "PV='${PV}'" "PKGNAME='${PKGNAME}'"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -eq '0' ;} ;then
  chroot-build || exit
fi

. "${PDIR%/}/etools.d/"pkg-tools-env || exit

if test "X${USER}" != 'Xroot'; then
  . "${PDIR%/}/etools.d/"sh-profile-tools || exit
fi

if test "${BUILD_CHROOT:=0}" -ne '0'; then
  . "${PDIR%/}/etools.d/"pre-env-chroot
fi

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  instdeps-spkg-dep || exit
  build-deps-fixfind
fi

if test "${BUILD_CHROOT:=0}" -ne '0'; then
  . "${PDIR%/}/etools.d/"ldpath-apply
fi

. "${PDIR%/}/etools.d/"path-tools-apply

WORKDIR="${PDIR%/}/${SRC_DIR}/${PKGNAME}-${PV}"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  : drop-ldconfig
  netuser-fetch
  sw-user
elif test "X${USER}" != 'Xroot'; then
  #17-prefix_cmake.sh
  #17-python.sh
  : drop-python

  #20-gen_variables.sh
  #20-hostname.sh
  #20-ldconfig.sh

  cd "${DISTSOURCE}/" || exit

  test -d "${WORKDIR}" && rm -r -- "${WORKDIR}/"
  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || exit

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  printf %s\\n "CC='${CC}'" "CXX='${CXX}'" "CPP='${CPP}'" "LIBTOOL='${LIBTOOL}'" "CFLAGS='${CFLAGS}'"
  printf %s\\n "CPPFLAGS='${CPPFLAGS}'" "CXXFLAGS='${CXXFLAGS}'" "FCFLAGS='${FCFLAGS}'" "FFLAGS='${FFLAGS}'"

  sed -i -e '/LIBREADLINE +=/ s/$/ -ltinfo/' Makefile

  #append-cflags -fPIC
  #CFLAGS=${CFLAGS:+${CFLAGS} }-fPIC

  INSTALL_OPTS=
  use 'shared' && INSTALL_OPTS="${INSTALL_DIR:+${INSTALL_DIR} }install-shared"
  use 'static-libs' && INSTALL_OPTS="${INSTALL_DIR:+${INSTALL_DIR} }install-static"

  #make release || exit
  . runverb \
  make shared || exit
  make \
    prefix="${INSTALL_DIR}" \
    bindir="${INSTALL_DIR}/bin" \
    libdir="${INSTALL_DIR}/${LIB_DIR}" \
    incdir="${INSTALL_DIR}/${INCDIR#/}" \
    ${INSTALL_OPTS} || exit
  printf %s\\n "make prefix=${INSTALL_DIR} ${INSTALL_OPTS}"

  cd "${INSTALL_DIR}/" || exit

  post-inst-perm

  RMLIST="$(pkg-rmlist)" pkg-rm

  post-rm
  pkg-rm-empty
  use 'strip' && pkg-strip
  use 'upx' && upx --best "bin/${PN}"
  pre-perm
fi

cd "${INSTALL_DIR}/" || exit

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  pkg-perm
elif { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -eq '0' ;} ;then
  INST_ABI=$(test-native-abi) pkg-create-cgz
fi
