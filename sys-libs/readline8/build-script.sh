#!/bin/sh
# Copyright (C) 2021-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-11-11 18:00 UTC / 2024-09-13 19:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# https://www.linuxfromscratch.org/lfs/view/11.2/chapter08/readline.html
# http://data.gpo.zugaina.org/gentoo/sys-libs/readline/readline-8.1_p2-r2.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Another cute console display library"
HOMEPAGE="https://tiswww.case.edu/php/chet/readline/rltop.html"
LICENSE="GPL-3+"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
PV="8.1"
PV="8.1.2"
SRC_URI="
  http://ftp.gnu.org/gnu/readline/readline-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/sys-libs/readline/files/readline-5.0-no_rpath.patch
  http://data.gpo.zugaina.org/gentoo/sys-libs/readline/files/readline-7.0-headers.patch
  http://data.gpo.zugaina.org/gentoo/sys-libs/readline/files/readline-8.0-headers.patch
  http://data.gpo.zugaina.org/gentoo/sys-libs/readline/files/readline-8.1-windows-signals.patch
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
IUSE="+ncurses +static-libs +shared -doc (+musl) +strip"
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
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
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
  "dev-util/pkgconf" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "#sys-libs/gpm  # deps ncurses (optional)" \
  "sys-libs/musl" \
  "sys-libs/ncurses  # optional" \
  || die "Failed install build pkg depend... error"

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

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
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

  # fix implicit decls with widechar funcs
  append-cppflags -D_GNU_SOURCE

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  ncurses_libs=$(${PKG_CONFIG} ncurses$(usex 'unicode' w) --libs)

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/${PN}-5.0-no_rpath.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-7.0-headers.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-8.0-headers.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-8.1-windows-signals.patch

  sed \
    -e "/^SHLIB_LIBS=/s:=.*:='${ncurses_libs}':" \
    -i support/shobj-conf || die
  sed \
    -e "/^[[:space:]]*LIBS=.-lncurses/s:-lncurses:${ncurses_libs}:" \
    -i examples/rlfe/configure || die

  . runverb \
  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/${LIB_DIR}" \
    --includedir="${INCDIR}" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --with-curses \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    $(use_enable 'examples' install-examples) \
    || die "configure... error"

  make -j1 || die "Failed make build"

  make DESTDIR="${ED}" install || die "make install... error"
  printf %s\\n "make DESTDIR=${ED} install"

  cd "${ED}/" || die "install dir: not found... error"

  rmdir -v "bin/"
  use 'doc' || rm -vr -- "usr/share/"

  if use !strip; then
    :
  else
    use 'static-libs' && strip --strip-unneeded "$(get_libdir)/"lib*.a
    strip --verbose --strip-all "$(get_libdir)/"lib*.so."${PV%.${PV#*.*.}}"
  fi

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  ldd "$(get_libdir)/"lib${PN}.so || { use 'static' && true || : die "library deps work... error";}
  ldd "$(get_libdir)/"libhistory.so || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
