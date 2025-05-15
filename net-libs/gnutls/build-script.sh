#!/bin/sh
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-11-08 18:00 UTC - last change

NL="$(printf '\n\t')"; NL=${NL%?} XPWD=${XPWD:=$PWD} XPN=${PN} PKG_DIR='/pkg' LC_ALL='C'

USER=${USER:-root}
USE_BUILD_ROOT=${USE_BUILD_ROOT:-1}
BUILD_CHROOT=${BUILD_CHROOT:-0}
LIBDIR=${LIBDIR:-/libx32}
INSTALL='install'

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
printf %s\\n "BUILDLIST='${BUILDLIST}'" "FAKETIME='${FAKETIME}'"

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

WORKDIR="${PDIR%/}/${SRC_DIR}/${PKGNAME}-src"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  : drop-ldconfig
  netuser-fetch
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

  #${ZCOMP} -dc ${F} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -
  pkg-unpack PKGNAME=${PKGNAME} && USE_BUILD_ROOT='0'

  cd "${WORKDIR}/" || exit

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  use 'strip' && INSTALL='install-strip'

  printf %s\\n "CC='${CC}'" "CXX='${CXX}'" "CPP='${CPP}'" "LIBTOOL='${LIBTOOL}'" "CFLAGS='${CFLAGS}'"
  printf %s\\n "CPPFLAGS='${CPPFLAGS}'" "CXXFLAGS='${CXXFLAGS}'" "FCFLAGS='${FCFLAGS}'" "FFLAGS='${FFLAGS}'"

  . runverb \
  ./configure \
    --prefix="${SPREFIX%/}" \
    --bindir="${SPREFIX%/}/bin" \
    --sbindir="${SPREFIX%/}/sbin" \
    --libdir="${SPREFIX%/}/${LIB_DIR}" \
    --includedir=${INCDIR} \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=${CHOST} \
    --build=${CHOST} \
    --without-included-unistring \
    $(use_enable 'alpn' alpn-support) \
    $(use_enable 'anon-auth' anon-authentication) \
    $(use_enable 'dhe') \
    $(use_enable 'dtls' dtls-srtp-support) \
    $(use_enable 'gost') \
    $(use_enable 'ocsp') \
    $(use_enable 'psk' psk-authentication) \
    $(use_enable 'srp' srp-authentication) \
    --disable-valgrind-tests \
    $(use_enable 'man' manpages) \
    $(use_enable 'doc' gtk-doc) \
    $(use_enable 'doc') \
    $(use_enable 'seccomp' seccomp-tests) \
    $(use_enable 'test' tests) \
    $(use_enable 'test-full' full-test-suite) \
    $(use_enable 'tools') \
    $(use_enable 'cxx') \
    $(use_enable 'dane' libdane) \
    $(use_enable 'openssl' openssl-compatibility) \
    $(use_enable 'sha1' sha1-support) \
    $(use_enable 'sslv2' ssl2-support) \
    $(use_enable 'sslv3' ssl3-support) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    $(use_enable 'tls-heartbeat' heartbeat-support) \
    $(use_with 'brotli') \
    $(use_with 'idn') \
    $(use_with 'pkcs11' p11-kit) \
    $(use_with 'zlib') \
    $(use_with 'zstd') \
    $(use_enable 'nls') \
    $(use_enable 'rpath') \
    $(use_with 'tpm2') \
    $(use_with 'tpm') \
    --without-included-libtasn1 || exit

  make || exit
  make DESTDIR="${INSTALL_DIR}" ${INSTALL} || exit
  printf %s\\n "make DESTDIR=${INSTALL_DIR} ${INSTALL}"

  cd "${INSTALL_DIR}/" || exit

  post-inst-perm

  RMLIST="$(pkg-rmlist)" pkg-rm

  post-rm
  pkg-rm-empty
  pre-perm
  exit
fi

cd "${INSTALL_DIR}/" || exit

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  pkg-perm
elif { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -eq '0' ;} ;then
  INST_ABI=$(test-native-abi) pkg-create-cgz
fi
