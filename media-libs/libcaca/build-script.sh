#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-04-28 17:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/media-libs/libcaca/libcaca-0.99_beta19-r11.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="A library that creates colored ASCII-art graphics"
HOMEPAGE="http://libcaca.zoy.org/"
LICENSE="GPL-2 ISC LGPL-2.1 WTFPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PV="0.99.beta19"
XPV="0.99b19"
SRC_URI="ftp://mirrors.tera-byte.com/pub/gentoo/distfiles/${PN}-${PV}.tar.gz"
SRC_URI="http://libcaca.zoy.org/files/${PN}/${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-doc -imlib -ncurses -opengl -slang +static-libs -test -truetype -X +shared (+musl) +stest +strip"
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
PROG="img2txt"

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
  "dev-lang/perl  # required for autotools" \
  "dev-util/pkgconf" \
  "sys-apps/file" \
  "dev-build/autoconf71  # required for autotools" \
  "dev-build/automake16  # required for autotools" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/libtool  # required for autotools,libtoolize" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "#sys-libs/ncurses" \
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
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  if use !shared && use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # bug #339962
  sed -e '/doxygen_tests = check-doxygen/d' -i test/Makefile.am || die

  sed \
   -e 's:-g -O2 -fno-strength-reduce -fomit-frame-pointer::' \
   -e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:' \
   -i configure.ac || die

  if ! use 'truetype'; then
    sed -e '/PKG_CHECK_MODULES/s:ftgl:dIsAbLe&:' -i configure.ac || die
  fi

  if use 'imlib' && ! use 'X'; then
    append-cflags -DX_DISPLAY_MISSING
  fi

  # bug #653400
  append-cxxflags -std=c++11

  # bug #601902, bug #825058
  use 'ncurses' && append-libs $(${PKG_CONFIG} --libs tinfow || die)

  # fix docs install path, bug 543870#c14
  sed -e "s/libcaca-dev/${PN}-${PV}/g" -i doc/Makefile.am || die

  test -x "/bin/perl" && autoreconf --install

  # bug #44128
  export VARTEXFONTS="${BUILD_DIR}/fonts"

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'slang') \
    $(use_enable 'ncurses') \
    $(use_enable 'X' x11) \
    $(use_with 'X' x) \
    --x-libraries=/$(get_libdir) \
    $(use_enable 'opengl' gl) \
    --enable-cxx \
    $(use_enable 'imlib' imlib2) \
    $(use_enable 'test' cppunit) \
    --disable-java \
    --disable-ruby \
    --disable-python \
    --disable-csharp \
    $(use_enable 'doc') \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || : die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -r -- "usr/share/man/"

  find "$(get_libdir)/" -name '*.la' -delete || die

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'stest' && { bin/${PROG} --version || die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${XPV} pkg-create-cgz