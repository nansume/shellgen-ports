#!/bin/sh
# Copyright (C) 2022-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-11-09 12:00 UTC - last change

NL="$(printf '\n\t')"; NL=${NL%?} XPWD=${XPWD:=$PWD} XPN=${PN} PKG_DIR='/pkg' LC_ALL='C'

USER=${USER:-root}
USE_BUILD_ROOT=${USE_BUILD_ROOT:-1}
BUILD_CHROOT=${BUILD_CHROOT:-0}
LIBDIR=${LIBDIR:-/libx32}
INSTALL_OPTS='install'

export USER BUILDLIST XPN PF PV LIBDIR WORKDIR PKGNAME

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
printf %s\\n "BUILDLIST='${BUILDLIST}'"

. "${PDIR%/}/etools.d/"pre-env || exit

read -r PF < 'src_uri.lst'
test "x${SN}" != "x${SN%%_*}" && SN="${SN%%_*}-${SN#*_}"
PF=${PF##*[/ ]}
PV=$(pkgver)
printf %s\\n "PV='${PV}'"

PKGNAME=$(pkgname)
printf %s\\n "PKGNAME='${PKGNAME}'"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -eq '0' ;} ;then
  chroot-build || exit
  USE_BUILD_ROOT='0'
fi

. "${PDIR%/}/etools.d/"pkg-tools-env || exit

if test "X${USER}" != 'Xroot'; then
  . "${PDIR%/}/etools.d/"sh-profile-tools || exit
fi

if test "${BUILD_CHROOT:=0}" -ne '0'; then
  . "${PDIR%/}/etools.d/"pre-env-chroot
fi

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  instdeps-spkg-dep
  build-deps-fixfind
fi

if test "${BUILD_CHROOT:=0}" -ne '0'; then
  . "${PDIR%/}/etools.d/"ldpath-apply
fi

. "${PDIR%/}/etools.d/"path-tools-apply

WORKDIR="${PDIR%/}/${SRC_DIR}/${PKGNAME}-${PV}/build"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  : drop-ldconfig
  netuser-fetch || exit
  sw-user
elif test "X${USER}" != 'Xroot'; then
  INCDIR="${DPREFIX}/include"
  USE_BUILD_ROOT='0'

  #17-prefix_cmake.sh
  #17-python.sh
  : drop-python

  #20-gen_variables.sh
  #20-hostname.sh
  #20-ldconfig.sh

  cd "${DISTSOURCE}/" || exit

  gunzip -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "gunzip -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  USE_BUILD_ROOT='0'

  mkdir "${WORKDIR}/"
  cd "${WORKDIR}/" || exit

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  use 'strip' && INSTALL_OPTS='install/strip'

  printf %s\\n "CC='${CC}'" "CXX='${CXX}'" "CPP='${CPP}'" "LIBTOOL='${LIBTOOL}'" "CFLAGS='${CFLAGS}'"
  printf %s\\n "CPPFLAGS='${CPPFLAGS}'" "CXXFLAGS='${CXXFLAGS}'" "FCFLAGS='${FCFLAGS}'" "FFLAGS='${FFLAGS}'"

  . runverb \
  cmake \
  -DCMAKE_INSTALL_PREFIX="" \
  -DCMAKE_INSTALL_BINDIR="bin" \
  -DCMAKE_INSTALL_SBINDIR="sbin" \
  -DCMAKE_INSTALL_LIBDIR="${LIB_DIR}" \
  -DCMAKE_INSTALL_INCLUDEDIR="${INCDIR}" \
  -DCMAKE_INSTALL_LIBEXECDIR="${DPREFIX}/libexec" \
  -DCMAKE_INSTALL_DATAROOTDIR="${DPREFIX}/share" \
  -DENABLE_GTK_DOC="OFF" \
  -DICAL_GLIB="OFF" \
  -DSTATIC_ONLY=$(usex 'shared' OFF ON) \
  -DSHARED_ONLY=$(usex 'static-libs' OFF ON) \
  -DCMAKE_BUILD_TYPE="Release" \
  -Wno-dev .. || exit

  make || exit
  make DESTDIR="${INSTALL_DIR}" ${INSTALL_OPTS} || exit
  printf %s\\n "make DESTDIR=${INSTALL_DIR} ${INSTALL_OPTS}"

  cd "${INSTALL_DIR}/" || exit

  post-inst-perm

  RMLIST="$(pkg-rmlist)" pkg-rm

  post-rm
  pkg-rm-empty
  pre-perm
fi

cd "${INSTALL_DIR}/" || exit

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  pkg-perm
elif { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -eq '0' ;} ;then
  INST_ABI=$(test-native-abi) pkg-create-cgz
fi
