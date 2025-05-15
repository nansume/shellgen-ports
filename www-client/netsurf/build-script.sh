#!/bin/sh
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-11-29 22:00 UTC - last change

NL="$(printf '\n\t')"; NL=${NL%?} XPWD=${XPWD:=$PWD} XPN=${PN} PKG_DIR='/pkg' LC_ALL='C'

LICENSE="GPL-2-with-OpenSSL-exception MIT"
USER=${USER:-root}
USE_BUILD_ROOT='0'
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=${PWD}
LIBDIR=${LIBDIR:-/libx32}
DPREFIX='/usr'
INCDIR="${DPREFIX}/include"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:${DPREFIX}/share/pkgconfig"
MAKEFLAGS='-j4 V=0'
CFLAGS='-O2 -msse2 -fno-stack-protector -g0'
CPPFLAGS='-O2 -msse2 -fno-stack-protector -g0'
CXXFLAGS='-O2 -msse2 -fno-stack-protector -g0'
FCFLAGS='-O2 -msse2 -fno-stack-protector -g0'
FFLAGS='-O2 -msse2 -fno-stack-protector -g0'
HOSTNAME=$(hostname)
BUILD_USER='tools'
SRC_DIR='build'
IONICE_COMM='nice -n 19'
ZCOMP='gunzip'

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

. "${PDIR%/}/etools.d/"pre-env || exit

test "x${SN}" != "x${SN%%_*}" && SN="${SN%%_*}-${SN#*_}"

PF=$(pfname 'src_uri.lst')
PV=$(pkgver)
PKGNAME=$(pkgname)
ZCOMP=$(zcomp-as "${PF}")

printf %s\\n "BUILDLIST='${BUILDLIST}'" "PV='${PV}'" "PKGNAME='${PKGNAME}'"

chroot-build || exit

. "${PDIR%/}/etools.d/"sh-profile-tools
. "${PDIR%/}/etools.d/"pre-env-chroot
. "${PDIR%/}/etools.d/"build-functions  # add func utils: append-cflags

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
  . "${PDIR%/}/etools.d/"gen-variables

  cd "${DISTSOURCE}/" || exit

  test -d "${WORKDIR}" && rm -rf -- "${WORKDIR}/"
  emptydir "${INSTALL_DIR}" || rm -r -- "${INSTALL_DIR}/"*

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || exit

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  #use 'static' && export CC='gcc -static --static'

  src-patch

  printf %s\\n "MAKEFLAGS='${MAKEFLAGS}'"
  printf %s\\n "CC='${CC}'" "CXX='${CXX}'" "CPP='${CPP}'" "LIBTOOL='${LIBTOOL}'"
  printf %s\\n "CFLAGS='${CFLAGS}'" "CPPFLAGS='${CPPFLAGS}'" "CXXFLAGS='${CXXFLAGS}'"
  printf %s\\n "FCFLAGS='${FCFLAGS}'" "FFLAGS='${FFLAGS}'" "LDFLAGS='${LDFLAGS}'"

	# compat busybox <bb-install>, <bb-xxd>
  sed -i '/$(INSTALL)/ s/ -T / /' frontends/framebuffer/Makefile
  sed -i '/xxd / s/ \$< / $< > /' content/handlers/javascript/duktape/Makefile

  . runverb \
  make \
  	DESTDIR="${INSTALL_DIR}" \
    PREFIX="${DPREFIX}" \
    NSSHARED="${DPREFIX}/share/netsurf-buildsystem" \
    NETSURF_FB_FONTLIB=$(usex 'truetype' freetype internal) \
 		NETSURF_FB_FONTPATH="${DPREFIX}/share/fonts/dejavu:${DPREFIX}/share/fonts/liberation-fonts" \
 		NETSURF_FB_FRONTEND=$(usex 'fbcon' sdl linux) \
 		NETSURF_USE_BMP=$(usex 'bmp' YES NO) \
 		NETSURF_USE_DUKTAPE=$(usex 'javascript' YES NO) \
 		NETSURF_USE_GIF=$(usex 'gif' YES NO) \
 		NETSURF_USE_JPEG=$(usex 'jpeg' YES NO) \
 		NETSURF_USE_PNG=$(usex 'png' YES NO) \
 		NETSURF_USE_NSPSL=$(usex 'psl' YES NO) \
 		NETSURF_USE_NSSVG=$(usex 'svg' YES NO) \
 		NETSURF_USE_OPENSSL=$(usex 'openssl' YES NO) \
 		NETSURF_USE_ROSPRITE="NO" \
 		NETSURF_USE_RSVG="NO" \
 		NETSURF_USE_WEBP=$(usex 'webp' YES NO) \
 		NETSURF_USE_VIDEO="NO" \
 		NETSURF_STRIP_BINARY=$(usex 'strip' YES NO) \
    COMPONENT_TYPE="binary" \
    TARGET="framebuffer" \
    all install || exit

  cd "${INSTALL_DIR}/" || exit

  mv -n "${DPREFIX#/}/bin" .

  post-inst-perm

  RMLIST="$(pkg-rmlist)" pkg-rm

  post-rm
  pkg-rm-empty
  pre-perm
  exit
fi

cd "${INSTALL_DIR}/" || exit

pkg-perm

INST_ABI="$(test-native-abi)" pkg-create-cgz
