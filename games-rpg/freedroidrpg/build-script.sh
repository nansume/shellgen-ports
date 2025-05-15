#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-04-02 16:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/games-rpg/freedroidrpg/freedroidrpg-1.0-r1.ebuild
# ports/games-rpg/freedroidrpg/freedroidrpg-9999.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH LIBS

DESCRIPTION="Modification of the classical Freedroid engine into an RPG"
HOMEPAGE="https://www.freedroid.org/"
LICENSE="GPL-2+"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
#PN="freedroidRPG"
PV="1.0"
PV="0.16.1"
SRC_URI="
  http://ftp.osuosl.org/pub/freedroid/freedroidRPG-${PV%.${PV#*.*.}}/freedroidRPG-${PV}.tar.gz
  #http://data.gpo.zugaina.org/gentoo/games-rpg/freedroidrpg/files/freedroidrpg-1.0-AC_INCLUDES_DEFAULT.patch
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
IUSE="-nls -debug -devtools -opengl -profile +sound +static -shared -doc (+musl) +stest +strip"
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
PROG="freedroidRPG"

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
  "#dev-lang/miniperl  # required for autotools" \
  "dev-lang/python38" \
  "dev-libs/expat  # for fontconfig or python bundled" \
  "dev-util/pkgconf" \
  "media-libs/libjpeg-turbo3" \
  "media-libs/libpng" \
  "media-libs/libogg" \
  "media-libs/libvorbis" \
  "media-libs/sdl  # needed: media-libs/sdl[video]" \
  "media-libs/sdl-gfx" \
  "media-libs/sdl-image" \
  "media-libs/sdl-mixer" \
  "sys-apps/findutils" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "#sys-devel/gettext-tiny  # required for autotools (optional)" \
  "#sys-devel/libtool  # required for autotools,libtoolize" \
  "#sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl  # testing" \
  "sys-libs/musl0" \
  "sys-libs/zlib  # for libpng" \
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

  . "${PDIR%/}/etools.d/"epython

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  if use !shared || use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-ldflags "-s -static --static"
    append-cflags -ffunction-sections -fdata-sections
    LIBS="-lSDL -lSDL_image -lpng -ljpeg -lz -lm"
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  sed -e '/^dist_doc_DATA/d' -e '/-pipe/d' -e '/^SUBDIRS/s/pkgs//' -i Makefile.am || die
  #python_fix_shebang src data/sound
  #eautoreconf

  #patch -p1 -E < "${FILESDIR}"/${PN}-1.0-AC_INCLUDES_DEFAULT.patch

  rm -- "data/sound/speak.py" || : die  # unused, skip install + python rdep

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --datadir="${EPREFIX%/}"/usr/share \
    --localedir=/usr/share/locale \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --enable-fastmath \
    --with-embedded-lua \
    $(use_enable 'debug' backtrace) \
    $(use_enable 'debug') \
    $(use_enable 'devtools' dev-tools) \
    $(use_enable 'opengl') \
    $(use_enable 'profile' rtprof) \
    $(use_enable 'sound') \
    $(use_with 'debug' extra-warnings) \
    --disable-nls \
    --disable-rpath \
    || die "configure... error"

  # nocompat busybox: <find>
  sed -e 's@\([[:space:]]\)find\([[:space:]]\)@\1/bin/find\2@' \
  -i Makefile Makefile.am Makefile.in \
   */Makefile */Makefile.am */Makefile.in \
   */*/Makefile */*/Makefile.am */*/Makefile.in \

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  for i in 48 64 96 128; do
    doicon -s ${i} pkgs/freedesktop/icons/hicolor/${i}x${i}/apps/freedroidrpg.png
  done
  doicon -s scalable pkgs/freedesktop/icons/hicolor/scalable/apps/freedroidRPG.svg
  : make_desktop_entry freedroidRPG "Freedroid RPG" freedroidRPG

  mv -n src/${PROG} -t "${ED}/bin/"

  cd "${ED}/" || die "install dir: not found... error"

  rm -r -- usr/share/doc/README-*

  strip --verbose --strip-all "bin/${PROG}"

  bin/${PROG} --version || die "binary work... error"
  ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz