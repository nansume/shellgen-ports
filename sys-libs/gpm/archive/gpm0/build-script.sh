#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2021-2025, 2025-06-29 01:00 UTC - last change
# Build with useflag: +static +static-libs +shared +ncurses +nopie +patch -doc -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sys-libs/gpm/gpm-1.20.7-r6.ebuild
# https://www.linuxfromscratch.org/blfs/view/svn/general/gpm.html  # rolling release - 12.3 - r954
# http://deb.debian.org/debian/pool/main/g/gpm/
# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=gpm-git

# Fix compilation with C23-supporting compilers, eg. GCC-15 and Clang-19
# https://github.com/telmich/gpm/pull/49

# vt: patch for set mouse selection word-chars to gpm's default
# https://www.spinics.net/lists/kernel/msg2474783.html

# BUG: error: implicit declaration of function <strcmp>
# TODO: in old_main.c add `#include <string.h>`
# BUG: libcurses.c: error: conflicting types for `WINDOW`; have `struct _WINDOW`

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="Console-based mouse driver"
HOMEPAGE="https://www.nico.schottelius.org/software/gpm/"
LICENSE="GPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:=$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
PV="1.20.7"
SRC_URI="
  https://www.nico.schottelius.org/software/${PN}/archives/${PN}-${PV}.tar.lzma
  #https://anduin.linuxfromscratch.org/BLFS/gpm/gpm-1.20.7.tar.bz2
  https://repo.iut.ac.ir/repo/gentoo-portage/${CATEGORY}/${PN}/files/${PN}-${PV}-sysmacros.patch
  https://repo.iut.ac.ir/repo/gentoo-portage/${CATEGORY}/${PN}/files/${PN}-${PV}-glibc-2.26.patch
  http://data.gpo.zugaina.org/gentoo/sys-libs/gpm/files/gpm-1.20.7-gcc-10.patch
  http://data.gpo.zugaina.org/gentoo/${CATEGORY}/${PN}/files/${PN}-${PV}-musl.patch
  http://data.gpo.zugaina.org/gentoo/${CATEGORY}/${PN}/files/${PN}-${PV}-gcc-include.patch
  http://data.gpo.zugaina.org/gentoo/${CATEGORY}/${PN}/files/${PN}-${PV}-signedness.patch
  #http://www.linuxfromscratch.org/patches/blfs/svn/gpm-1.20.7-consolidated-1.patch
  http://www.linuxfromscratch.org/patches/blfs/svn/gpm-1.20.7-gcc15_fixes-1.patch
  http://deb.debian.org/debian/pool/main/g/${PN}/${PN}_${PV}-11.debian.tar.xz
  https://gitlab.archlinux.org/archlinux/packaging/packages/gpm/-/raw/main/gpm.sh
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
IUSE="-selinux (+ncurses) (+syslog) (-test) -debug"
IUSE="${IUSE} +static +static-libs +shared -doc (-diet) (+musl) +stest +strip"
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
ZCOMP="unlzma"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
SYMVER="2.1.0"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
PATCH="patch"

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
  "sys-devel/binutils9" \
  "sys-devel/bison" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'patch' && {
pkginst \
  "dev-build/autoconf71" \
  "dev-build/automake16" \
  "dev-build/libtool9" \
  "dev-lang/perl" \
  "sys-devel/m4" \
  "sys-devel/gettext" \
  "sys-devel/patch" \
  || die "Failed install build pkg depend... error"
}

use 'ncurses' && pkginst "sys-libs/ncurses"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"  # only for user-build

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  pf=${PF}
  for PF in *.tar.lzma *.tar.gz *.tar.xz; do
    case ${PF} in '*.tar.'*) continue;; *.tar.xz) ZCOMP="unxz";; esac
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  printf %s\\n "MAKEFLAGS='${MAKEFLAGS}'"
  printf %s\\n "CC='${CC}'" "CXX='${CXX}'" "CPP='${CPP}'" "LIBTOOL='${LIBTOOL}'"
  printf %s\\n "CFLAGS='${CFLAGS}'" "CPPFLAGS='${CPPFLAGS}'" "CXXFLAGS='${CXXFLAGS}'"
  printf %s\\n "FCFLAGS='${FCFLAGS}'" "FFLAGS='${FFLAGS}'" "LDFLAGS='${LDFLAGS}'"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"
  test -L "/bin/g${PATCH}" || PATCH="/bin/${PATCH}"
  printf %s\\n "PATCH='${PATCH}'"

  #for F in "${FILESDIR}/"*".patch" "${WORKDIR}/debian/patches/"*".patch"; do
  #  ${PATCH} -p1 -E < "${F}"
  #done

  for F in $(sed -e 's:^:../debian/patches/:' ../debian/patches/series || die); do
    case ${F##*/} in 007_doc_fix_000 | 007_doc_fix_001 | 007_doc_fix_FAQ) continue;; esac
    printf '%s\n' "${PATCH} -p1 -E < ${F}"
    ${PATCH} -p1 -E < "${F}"
  done
  ${PATCH} -p1 -E < "${FILESDIR}"/${PN}-${PV}-gcc-include.patch
  #${PATCH} -p1 -E < "${FILESDIR}"/${PN}-${PV}-gcc15_fixes-1.patch

  # FIX: error: implicit declaration of function <strcmp>
  #sed -e '/^#include "headers\/gpmInt.h"/a #include <string.h>' -i src/daemon/old_main.c

  >>doc/gpm.info && printf %s\\n "create or skip: >>doc/gpm.info"

  ./autogen.sh &&
  . runverb \
  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_with 'ncurses' curses) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  ########################################################################################
  if use 'static'; then
    cd "${FILESDIR}/" || die "distsource dir: not found... error"

    PF=${pf} ZCOMP="unlzma"

    test -d "${BUILD_DIR}" && rm -rf -- "${BUILD_DIR}/"
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf -

    append-ldflags -Wl,--gc-sections
    append-ldflags "-s -static --static"
    append-flags -Os -ffunction-sections -fdata-sections

    cd "${BUILD_DIR}/"
    for F in $(sed -e 's:^:../debian/patches/:' ../debian/patches/series || die); do
      case ${F##*/} in 007_doc_fix_000 | 007_doc_fix_001 | 007_doc_fix_FAQ) continue;; esac
      printf '%s\n' "${PATCH} -p1 -E < ${F}"
      ${PATCH} -p1 -E < "${F}"
    done
    ${PATCH} -p1 -E < "${FILESDIR}"/${PN}-${PV}-gcc-include.patch
    #${PATCH} -p1 -E < "${FILESDIR}"/${PN}-${PV}-gcc15_fixes-1.patch

    #sed -e '/^#include "headers\/gpmInt.h"/a #include <string.h>' -i src/daemon/old_main.c

    ./autogen.sh &&
    ./configure \
      --host=$(tc-chost) \
      --build=$(tc-chost) \
      --without-curses \
      CC="${CC}" \
      LDFLAGS="${LDFLAGS}" \
      || die "Failed make build"
    make -j "$(nproc)" || true
    mv -f "src/${PN}" -t "${ED}/sbin/" || die
  fi
  ########################################################################################

  cd "${ED}/${LIB_DIR}/" || die "${ED}/${LIB_DIR}/: not found... error"
  # fix: not found <gpm> (lib)
  ln -sf "lib${PN}.so.${SYMVER}" "lib${PN}.so"
  ln -sf "lib${PN}.so.${SYMVER}" "lib${PN}.so.1"

  chmod +x "lib${PN}.so.${SYMVER}"

  cd "${ED}/" || die "install dir: not found... error"

  rm -v -r -- "usr/share/" "etc/"

  use 'strip' && strip --verbose --strip-all "sbin/${PN}"

  use 'static' && LD_LIBRARY_PATH=
  use 'stest' && { sbin/${PN} -v || die "binary work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

ldd "$(get_libdir)/lib${PN}.so" || die "library deps work... error"
ldd "sbin/${PN}" || { use 'static' && true || die "library deps work... error";}

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz