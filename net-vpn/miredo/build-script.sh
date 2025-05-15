#!/bin/sh
# Copyright (C) 2023-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-08-04 22:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="Miredo is an open-source Teredo IPv6 tunneling software"
HOMEPAGE="http://www.remlab.net/miredo/"
LICENSE="GPL-2"
IFS="$(printf '\n\t')"
DOCS="AUTHORS ChangeLog NEWS README TODO THANKS"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="1.3.0"
PV="1.2.6"
URI="git.freifunk-franken.de/mirror/openwrt-packages/raw/branch/master/ipv6"
SRC_URI="
  http://www.remlab.net/files/${PN}/${PN}-${PV}.tar.xz
  #http://www.remlab.net/files/${PN}/${PN}-e5f5652.tar.gz -> ${PN}-${PV}.tar.gz
  https://${URI}/miredo/patches/001-fix-musl-pthread-non-portable.patch
  https://${URI}/miredo/patches/002-fix-redefinition-ethadr.patch
  https://${URI}/miredo/patches/003-fix-warnings-portable-defined.patch
  https://${URI}/miredo/patches/004-reproducible.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-rpath -nls -static -static-libs +shared -doc +musl -caps -judy -debug +stest +strip"
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
ZCOMP="unxz"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-e5f5652"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
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
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-kernel/linux-headers-musl" \
  || die "Failed install build pkg depend... error"

use 'caps' && {
pkginst \
  "dev-lang/perl" \
  "sys-devel/autoconf" \
  "sys-devel/automake" \
  "sys-devel/m4" \
  "sys-devel/gettext" \
  "sys-devel/libtool" \
  "sys-libs/libcap" \
  || die "Failed install build pkg depend... error"
}

use 'judy' && pkginst "dev-libs/judy"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  use 'strip' && INSTALL_OPTS='install-strip'

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  cd "${BUILD_DIR}/" || die "builddir: not found... error"
  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  patch -p1 -E < "${FILESDIR}"/001-fix-musl-pthread-non-portable.patch
  patch -p1 -E < "${FILESDIR}"/002-fix-redefinition-ethadr.patch
  patch -p1 -E < "${FILESDIR}"/003-fix-warnings-portable-defined.patch
  patch -p1 -E < "${FILESDIR}"/004-reproducible.patch

  test -x "/bin/perl" && ./autogen.sh

  . runverb \
  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
    --build=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
    --disable-sample-conf \
    --without-Judy \
    $(usex 'caps' --without-libcap) \
    $(use_enable 'shared') \
    --disable-static \
    --disable-binreloc \
    --disable-nls \
    --disable-rpath \
    --disable-assert \
    --enable-teredo-client \
    --with-pic \
    --without-libiconv-prefix \
    --without-libintl-prefix \
    --enable-miredo-user \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  rm -vr -- "etc/" "$(get_libdir)/systemd/" "usr/include/" "usr/share/" "var/"  #bin/

  find "$(get_libdir)/" -name '*.la' -delete || die

  # simple test
  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  sbin/${PN} --version || die "binary work... error"

  ldd "sbin/${PN}" || die && { use 'static' && true;}

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
