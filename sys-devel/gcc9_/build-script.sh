#!/bin/sh
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-12-14 11:00 UTC - last change

# Usage [for bootstrap]: USE='+bootstrap +x32' emerge -b -- sys-devel/gcc

NL="$(printf '\n\t')"; NL=${NL%?} XPWD=${XPWD:=$PWD} XPN=${PN} PKG_DIR='/pkg' LC_ALL='C'

PV="9.5.0"
DESCRIPTION="The GNU Compiler Collection"
HOMEPAGE="https://gcc.gnu.org/"
SRC_URI="
  http://ftp.gnu.org/gnu/${PN}/${PN}-${PV}/${PN}-${PV}.tar.xz
  #http://musl.cc/x86_64-linux-muslx32-native.tgz
"

LICENSE="GPL-3+ LGPL-3+ || ( GPL-3+ libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.3+"

USER=${USER:-root}
USE_BUILD_ROOT='0'
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=${PWD}
DPREFIX='/usr'
INCDIR="${DPREFIX}/include"
INSTALL_OPTS='install'
HOSTNAME=$(hostname)
BUILD_USER='tools'
SRC_DIR='build'
IONICE_COMM='nice -n 19'
ZCOMP='unxz'
IUSE="-bootstrap -rpath -nls +static-libs +static -system-zlib +strip"
IUSE="${IUSE} +openmp -libssp -sanitize -multilib +lto +asm -libvtv +objc"

export BUILD_CHROOT
export USER XPN PF PV WORKDIR PKGNAME DPREFIX
export LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI

if test "X${USER}" != 'Xroot'; then
  ABI_BUILD=${1:?} LIBDIR=${2:?} LIB_DIR=${3:?} PDIR=${4:?} XPWD=${5:?} XPN=${6:?}
  BUILD_CHROOT=${7:?} USE_BUILD_ROOT=${9} BUILDLIST=${10} CATEGORY=${11:?} PN=${12:?}
  PWD=${PWD%/}
  mksrc-prepare
elif test "${BUILD_CHROOT:=0}" -eq '0'; then
  PATH="${PATH:+${PATH}:}${PDIR}/misc.d:${PDIR}/etools.d"
elif test "${BUILD_CHROOT:=0}" -ne '0'; then
  PATH="$(xpath):${PDIR%/}/misc.d:${PDIR%/}/etools.d"
  printf %s\\n "PATH='${PATH}'" "PDIR='${PDIR}'"
fi

EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
DPREFIX="/usr"
PDIR=${PWD}
P=${XPWD##*/}
SN=${P}
PN=${P%%_*}
PORTS_DIR=${PWD%/$P}
DISTSOURCE="/sources"
FILESDIR=${DISTSOURCE}
INSTALL_DIR="${PORTS_DIR}/${P}/install"
S="${PORTS_DIR}/${P}/${SRC_DIR}"
SDIR="${PORTS_DIR}/${P}/${SRC_DIR}"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
PKGNAME=$(pkgname)
ZCOMP=$(zcomp-as "${PF}")

export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTSOURCE FILESDIR INSTALL_DIR S SDIR

chroot-build || exit

. "${PDIR%/}/etools.d/"pre-env-chroot
. "${PDIR%/}/etools.d/"build-functions

WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"

use 'bootstrap' && tc-bootstrap-musl "$(arch)-linux-musl$(usex x32 x32 '')-native.tgz"

pkginst \
  "dev-libs/gmp" \
  "dev-libs/mpc" \
  "dev-libs/mpfr" \
  "sys-devel/binutils" \
  "sys-devel/bison" \
  "sys-devel/flex" \
  "sys-devel/libtool" \
  "sys-devel/m4" \
  "sys-devel/make" \
  "sys-kernel/linux-headers" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'bootstrap' ||
pkginst \
  "sys-devel/gcc" \
  "#sys-libs/musl"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  #ln -sf libc-2.28.so /lib/libc.so

  #rm -- bin/makeinfo
  rm -- bin/help2man bin/man bin/msgfmt bin/groff bin/python misc.d/groups
  rm -- bin/pod2html bin/pod2man bin/pod2text bin/soelim bin/xsltproc

  sw-user || die "Failed package build from user... error"
  exit
elif test "X${USER}" != 'Xroot'; then

  cd "${DISTSOURCE}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  case $(tc-abi-build) in
    'x32')
      append-flags -mx32 -msse2
    ;;
    'x86')
      append-flags -m32 -msse
    ;;
    'amd64')
      append-flags -m64 -msse2
    ;;
  esac
  append-flags -O2 -fno-stack-protector -g0 -march=$(arch | sed 's/_/-/')

  use 'strip' && INSTALL_OPTS='install-strip'

	IFS=${NL}

  . runverb \
  ./configure \
    CC="gcc$(use static && printf ' -static --static')" \
    CXX="g++$(use static && printf ' -static --static')" \
    CPP="cpp" \
    AR="ar" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --target=$(tc-chost) \
    --disable-bootstrap \
    --with-gxx-include-dir="${INCDIR}/c++" \
    --enable-languages="c,c++" \
    $(use_enable 'openmp' libgomp) \
    $(use_enable 'lto') \
    $(use_enable 'libssp') \
    $(use_enable 'sanitize' libsanitizer) \
    $(use_enable 'multilib') \
    $(use_with 'system-zlib') \
    $(use_enable 'nls') \
    --disable-libvtv \
    --enable-obsolete \
    --disable-gnu-indirect-function \
    $(use 'static' && printf "LDFLAGS=-s -static --static") \
    || die "configure... error"

  make -j "$(cpun)" || die "Failed make build"

  . runverb \
  make DESTDIR="${INSTALL_DIR}" ${INSTALL_OPTS} || die "make install... error"

  cd "${INSTALL_DIR}/" || die "install dir: not found... error"

  for X in bin/*-linux-musl-*; do
    case ${X##*/} in
      *'-linux-musl-c++')
        X=${X##*/}
        ln -vsf "${X%-*}-g++" "bin/${X}"
        ln -vsf "${X}" "bin/${X#*-linux-musl-}"
      ;;
      *"-linux-musl-gcc-${PV}")
        X=${X##*/}
        ln -vsf "${X}" "bin/${X%-*}"
      ;;
      *)
        ln -vsf "${X##*/}" "bin/${X#*-linux-musl-}"
      ;;
    esac
  done

  rm -r -- "usr/share/man" "usr/share/info"

  # simple test
  LD_LIBRARY_PATH= bin/${PN} --version || die "binary work... error"
  ldd "bin/${PN}" || { use 'static' && true;}

  exit
fi

cd "${INSTALL_DIR}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(test-native-abi)" pkg-create-cgz
