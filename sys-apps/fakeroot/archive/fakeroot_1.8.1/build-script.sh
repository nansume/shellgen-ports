#!/bin/sh
# Copyright (C) 2021-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-11-06 21:00 UTC - last change

NL="$(printf '\n\t')"; NL=${NL%?} XPWD=${XPWD:=$PWD} XPN=${PN} PKG_DIR='/pkg' LC_ALL='C'

: ${USER:=root} ${USE_BUILD_ROOT:=1} ${BUILD_CHROOT:=0}

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

LIBDIR=${LIBDIR:-/libx32}

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

if test "X${USER}" != 'Xroot'; then
  #17-prefix_cmake.sh
  #17-python.sh
  INCDIR="${DPREFIX}/include"
fi

WORKDIR="${PDIR%/}/${SRC_DIR}/${PKGNAME}-src"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  : drop-ldconfig
elif test "X${USER}" != 'Xroot'; then
  : drop-python
fi

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  netuser-fetch
  sw-user
elif test "X${USER}" != 'Xroot'; then
  USE_BUILD_ROOT='0'
fi

if test "X${USER}" != 'Xroot'; then
  #20-gen_variables.sh
  #20-hostname.sh
  #20-ldconfig.sh

  cd "${DISTSOURCE}/" || exit

  #${ZCOMP} -dc ${F} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -
  pkg-unpack PKGNAME=${PKGNAME} && USE_BUILD_ROOT='0'

  cd "${WORKDIR}/" || exit

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  case ${CHOST} in
    *'muslx32')
      # fakeroot-1.8.1: Invalid configuration <x86_64-linux-muslx32>: system <muslx32> not recognized
      P_CHOST='x86_64-pc-linux-gnux32'
      # musl does not have _STAT_VER, it's really not used for
      # anything, so define it as zero (just like uclibc does)
      # https://git.alpinelinux.org/aports/plain/main/fakeroot/APKBUILD
      CFLAGS="-D_STAT_VER=0 ${CFLAGS}"
    ;;
  esac
  printf %s\\n "CC='${CC}'" "CXX='${CXX}'" "CPP='${CPP}'" "LIBTOOL='${LIBTOOL}'" "CFLAGS='${CFLAGS}'"
  printf %s\\n "CPPFLAGS='${CPPFLAGS}'" "CXXFLAGS='${CXXFLAGS}'" "FCFLAGS='${FCFLAGS}'" "FFLAGS='${FFLAGS}'"

  . runverb \
  ./configure \
    --prefix=${SPREFIX} \
    --bindir=${SPREFIX%/}/bin \
    --sbindir=${SPREFIX%/}/sbin \
    --libdir=${SPREFIX%/}/${LIB_DIR} \
    --includedir=${INCDIR} \
    --libexecdir=${DPREFIX}/libexec \
    --datarootdir=${DPREFIX}/share \
    --host=${P_CHOST} \
    --build=${P_CHOST} \
    --disable-static || exit

  make || exit
  make DESTDIR='/install' install-strip || exit

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
fi
if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -eq '0' ;} ;then
  INST_ABI=$(test-native-abi) pkg-create-cgz
fi
