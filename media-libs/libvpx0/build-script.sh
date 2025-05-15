#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-04-21 14:00 UTC - last change
# Build with useflag: +static-libs +shared -ipv6 -ssl -doc -xstub +musl +stest +strip +x32

inherit build qt4-build python pkg-export build-functions

export USER XPN PF PV WORKDIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${PN}
XPN="${6:-${XPN:?}}"
PV="1.5.0"
DESCRIPTION="WebM VP8 Codec SDK"
HOMEPAGE="http://www.webmproject.org"
SRC_URI="
  http://storage.googleapis.com/downloads.webmproject.org/releases/webm/${PN}-${PV}.tar.bz2
  http://shellgen.mooo.com/pub/distfiles/patch/${PN}/${PN}-1.5.0-x32.patch
"
LICENSE="BSD"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="linux"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static-libs +shared (+musl) (-patch) (-debug) +stest -test +strip"
IUSE="${IUSE} -nls -rpath -svc +threads -postproc -doc -xstub"
IUSE="${IUSE} -cpu_flags_x86_avx -cpu_flags_x86_avx2 +cpu_flags_x86_mmx +cpu_flags_x86_sse"
IUSE="${IUSE} +cpu_flags_x86_sse2 -cpu_flags_x86_sse3 -cpu_flags_x86_ssse3 -cpu_flags_x86_sse4_1"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
P="${P:-${XPWD##*/}}"
SN=${P}
PN="${PN:-${P%%_*}}"
PN=${12:-$PN}
PORTS_DIR=${PWD%/$P}
DISTDIR="/usr/distfiles"
DISTSOURCE="${PDIR%/}/sources"
FILESDIR=${DISTSOURCE}
INSTALL_DIR="${PDIR%/}/install"
ED=${INSTALL_DIR}
SDIR="${PDIR%/}/${SRC_DIR}"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
PKGNAME=${PN}
ZCOMP="bunzip2"
WORKDIR="${PDIR%/}/${SRC_DIR}/${PKGNAME}_${XPV}"
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
S="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
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
  "dev-lang/perl" \
  "dev-lang/yasm" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"  # only for user-build

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  # od: unrecognized option: A - busybox nocompat
  # required fix

  case $(tc-abi-build) in
    'x32')
      patch -p1 -E < "${FILESDIR}/${PN}-1.5.0-x32.patch"
      append-flags -mx32 -msse2
    ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc"

	IFS=${NL}

  . runverb \
  ./configure \
    --prefix="${EPREFIX%/}/usr" \
    --libdir="${EPREFIX%/}/usr/$(get_libdir)" \
    --enable-pic \
    --enable-vp8 \
    --enable-vp9 \
    --extra-cflags="${CFLAGS}" \
    $(use_enable 'cpu_flags_x86_avx' avx) \
    $(use_enable 'cpu_flags_x86_avx2' avx2) \
    $(use_enable 'cpu_flags_x86_mmx' mmx) \
    $(use_enable 'postproc') \
    $(use 'cpu_flags_x86_sse2' && use_enable 'cpu_flags_x86_sse' sse || printf --disable-sse) \
    $(use_enable 'cpu_flags_x86_sse2' sse2) \
    $(use_enable 'cpu_flags_x86_sse3' sse3) \
    $(use_enable 'cpu_flags_x86_sse4_1' sse4_1) \
    $(use_enable 'cpu_flags_x86_ssse3' ssse3) \
    $(use_enable 'svc' experimental) \
    $(use_enable 'svc' spatial-svc) \
    $(use_enable 'test' unit-tests) \
    $(use_enable 'threads' multithread) \
    --disable-examples \
    --disable-install-docs \
    --disable-docs \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc --ignore=1)" GEN_EXAMPLES= || die "Failed make build"

  # pkg install uses only --strip-debug
  . runverb \
  make GEN_EXAMPLES= DESTDIR="${ED}" install || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  mv -vn "usr/$(get_libdir)" .
  sed -i "4s|^libdir=.*|libdir=/$(get_libdir)|;t" $(get_libdir)/pkgconfig/"vpx.pc"

  # install uses strip <--strip-debug>, it safe.
  if use 'static-libs'; then
    strip --strip-unneeded "$(get_libdir)/"${PN}.a "$(get_libdir)/"${PN}.a.*
  else
    strip --verbose --strip-all "$(get_libdir)/"${PN}.so "$(get_libdir)/"${PN}.so.*
  fi

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
