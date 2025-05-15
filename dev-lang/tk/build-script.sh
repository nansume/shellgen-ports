#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-10 18:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs -upx +patch -doc -xstub -diet +musl +stest +strip +x32

export USER XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

# Please bump with dev-lang/tcl!

DESCRIPTION="Tk Widget Set"
HOMEPAGE="https://www.tcl.tk/"
LICENSE="tcltk"
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="8.6.13"
SRC_URI="
  https://downloads.sourceforge.net/tcl/${PN}${PV}-src.tar.gz
  http://data.gpo.zugaina.org/gentoo/dev-lang/tk/files/tk-8.6.10-multilib.patch
  #http://data.gpo.zugaina.org/gentoo/dev-lang/tk/files/tk-8.4.15-aqua.patch
  http://data.gpo.zugaina.org/gentoo/dev-lang/tk/files/tk-8.6.9-conf.patch
  http://data.gpo.zugaina.org/gentoo/dev-lang/tk/files/tk-8.6.12-test.patch
  http://data.gpo.zugaina.org/gentoo/dev-lang/tk/files/tk-8.6.13-test.patch
"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-debug +threads +truetype -aqua +xscreensaver"
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
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}${PV}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}${PV}/unix"
#WORKDIR=${BUILD_DIR}
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}

SPARENT="${PDIR%/}/${SRC_DIR}/${PN}${PV}"
S=${BUILD_DIR}

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
  "dev-lang/tcl" \
  "dev-libs/expat  # for xft?" \
  "dev-util/pkgconf" \
  "media-libs/freetype  # for xft?" \
  "media-libs/fontconfig  # for xft?" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "x11-base/xcb-proto  # for xft?" \
  "x11-base/xorg-proto" \
  "x11-libs/libice" \
  "x11-libs/libsm" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxcursor" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxfixes" \
  "x11-libs/libxft  # optional or --disable-xft" \
  "x11-libs/libxrender  # for xft (optional)" \
  "x11-libs/libxscrnsaver  # optional" \
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

  inherit autotools toolchain-funcs install-functions

  #WORKDIR=${SPARENT}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"
  printf %s\\n "cd ${WORKDIR}/"

  patch -p1 -E < "${FILESDIR}"/${PN}-8.6.10-multilib.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-8.6.9-conf.patch  # Bug 125971
  patch -p1 -E < "${FILESDIR}"/${PN}-8.6.12-test.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-8.6.13-test.patch

  cd "${BUILD_DIR}/" || die "builddir: not found... error"
  printf %s\\n "cd ${BUILD_DIR}/"

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

  CC="gcc$(usex static ' --static')"
  CXX="g++$(usex static ' --static')"

  use 'strip' && INSTALL_OPTS="install-strip"

  find "${SPARENT}"/compat/* -delete || die

  # Make sure we use the right pkg-config, and link against fontconfig
  # (since the code base uses Fc* functions).
  sed \
    -e 's/FT_New_Face/XftFontOpen/g' \
    -e "s:\<pkg-config\>:${PKG_CONFIG}:" \
    -e 's:xft freetype2:xft freetype2 fontconfig:' \
    -i configure.in || die
  #rm configure || die

  sed -e '/chmod/s:555:755:g' -i Makefile.in || die
  sed -e 's:-O[2s]\?::g' -i tcl.m4 || die

  #mv configure.in configure.ac || die

  : eautoconf

  # is --prefix=${EPREFIX%/} replace with --prefix=${EPREFIX} same to <dev-lang/tcl>
  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --with-tcl="${EPREFIX%/}/${LIB_DIR}" \
    $(use_enable 'threads') \
    $(use_enable 'aqua') \
    $(use_enable 'truetype' xft) \
    $(use_enable 'xscreensaver' xss) \
    $(use_enable 'debug' symbols) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    $(use_enable 'nls') \
    $(use_enable 'rpath') \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  v1=${PV%.*}
  mylibdir=$(get_libdir)  # replace with LIB_DIR

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  # fix the tkConfig.sh to eliminate refs to the build directory
  # and drop unnecessary -L inclusion to default system libdir

  sed \
    -e "/^TK_BUILD_LIB_SPEC=/s:-L${BUILD_DIR} ::g" \
    -e "/^TK_LIB_SPEC=/s:-L${EPREFIX%/}/${mylibdir} *::g" \
    -e "/^TK_SRC_DIR=/s:${SPARENT}:${EPREFIX%/}/${mylibdir}/tk${v1}/include:g" \
    -e "/^TK_BUILD_STUB_LIB_SPEC=/s:-L${BUILD_DIR} ::g" \
    -e "/^TK_STUB_LIB_SPEC=/s:-L${EPREFIX%/}/${mylibdir} *::g" \
    -e "/^TK_BUILD_STUB_LIB_PATH=/s:${BUILD_DIR}:${EPREFIX%/}/${mylibdir}:g" \
    -e "/^TK_LIB_FILE=/s:'libtk${v1}..TK_DBGX..so':\"libk${v1}\$\{TK_DBGX\}.so\":g" \
    -i "${ED}"/${mylibdir}/tkConfig.sh || die

  # install private headers
  insinto /${mylibdir}/tk${v1}/include/unix
  doins "${BUILD_DIR}"/*.h
  insinto /${mylibdir}/tk${v1}/include/generic
  doins "${SPARENT}"/generic/*.h
  rm -f "${ED}"/${mylibdir}/tk${v1}/include/generic/tk.h || die
  rm -f "${ED}"/${mylibdir}/tk${v1}/include/generic/tkDecls.h || die
  rm -f "${ED}"/${mylibdir}/tk${v1}/include/generic/tkPlatDecls.h || die

  # install symlink for libraries
  ln -s libtk${v1}.so ${mylibdir}/libtk.so
  ln -s libtkstub${v1}.a ${mylibdir}/libtkstub.a

  ln -s wish${v1} bin/wish
  dodoc "${SPARENT}"/ChangeLog* "${SPARENT}"/README.md "${SPARENT}"/changes

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'stest' && { bin/wish -v || : die "binary work... error";}
  ldd "bin/wish" || { use 'static' && true;}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
