#!/bin/sh
# Copyright (C) 2021-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-11-12 20:00 UTC - last change

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
MAKEFLAGS=
#HOSTNAME=$(hostname)

export USER BUILDLIST XPN PF PV LIBDIR WORKDIR PKGNAME DPREFIX PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

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

. "${PDIR%/}/etools.d/"pkg-tools-env
. "${PDIR%/}/etools.d/"sh-profile-tools
. "${PDIR%/}/etools.d/"pre-env-chroot

instdeps-spkg-dep || exit
build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

WORKDIR="${PDIR%/}/${SRC_DIR}/${PKGNAME}-${PV}"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  no-ldconfig
  netuser-fetch || exit
  sw-user || exit
elif test "X${USER}" != 'Xroot'; then
  #17-prefix_cmake.sh
  #17-python.sh
  : drop-python

  #20-gen_variables.sh

  cd "${DISTSOURCE}/" || exit

  test -d "${WORKDIR}" && rm -r -- "${WORKDIR}/"
  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || exit

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  use 'strip' && INSTALL_OPTS='install-strip'
  # for compilation: -fdata-sections, -ffunction-sections, -fvisibility=hidden, -fvisiblity-inlines-hidden
  # for linkage: -Wl,--gc-sections, -Bsymbolic, -Wl,--exclude-libs,ALL
  use 'static' && export LDFLAGS='-static'

  printf %s\\n "MAKEFLAGS='${MAKEFLAGS}'"
  printf %s\\n "CC='${CC}'" "CXX='${CXX}'" "CPP='${CPP}'" "LIBTOOL='${LIBTOOL}'"
  printf %s\\n "CFLAGS='${CFLAGS}'" "CPPFLAGS='${CPPFLAGS}'" "CXXFLAGS='${CXXFLAGS}'"
  printf %s\\n "FCFLAGS='${FCFLAGS}'" "FFLAGS='${FFLAGS}'" "LDFLAGS='${LDFLAGS}'"

  . runverb \
  ./configure \
    --prefix=${SPREFIX} \
    --bindir="${SPREFIX%/}/bin" \
    --sbindir="${SPREFIX%/}/sbin" \
    --libdir="${SPREFIX%/}/${LIB_DIR}" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=${CHOST} \
    --build=${CHOST} \
    $(use_enable 'nls') \
    $(use_enable 'rpath') \
    $(use_enable 'color') \
    --disable-year2038 \
    --disable-browser \
    --disable-extra \
    $(use_enable 'help') \
    --disable-histories \
    --disable-justify \
    --disable-largefile \
    $(use_enable 'magic' libmagic) \
    $(use_enable 'gpm' mouse) \
    --disable-multibuffer \
    $(use_enable 'color' nanorc) \
    --disable-operatingdir \
    --disable-speller \
    --disable-tabcomp \
    --disable-threads \
    --disable-wordcomp \
    --disable-wrapping \
    $(use_enable 'tiny') || exit

  make || exit

  . runverb \
  make DESTDIR="${INSTALL_DIR}" ${INSTALL_OPTS} || exit

  cd "${INSTALL_DIR}/" || exit

  if use 'extra' && test -d "${DPREFIX#/}/share/${PN}/extra"; then
    mv -n "${DPREFIX#/}/share/${PN}/extra/"* "${DPREFIX#/}/share/${PN}/"
  fi

  use 'color' && {
  sed -i -e 's:env|\(keywords\):\1:' usr/share/nano/gentoo.nanorc
  sed -i \
    -e 's|^\(syntax .*\)$|\1 "\\\.env\$"|' \
    -e 's|^\(syntax .*\)$|\1 "\\\.ipxe\$"|' \
    -e 's|^\(syntax .*\)$|\1 "\\\.[0-9]\$"|' \
    -e '/header/ s%\(runscript\)%ipxe|\1%' \
    -e '/header/ s|/||' \
    -e '10s|\(brightgreen ..\)|\1\[ \]\*|' \
    usr/share/nano/sh.nanorc
  }

  post-inst-perm

  RMLIST="$(pkg-rmlist)" pkg-rm

  post-rm
  pkg-rm-empty
  use 'upx' && upx --best "bin/${PN}"
  pre-perm
  exit
fi

cd "${INSTALL_DIR}/" || exit

pkg-perm

INST_ABI="$(test-native-abi)" pkg-create-cgz
