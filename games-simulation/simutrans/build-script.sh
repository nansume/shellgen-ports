#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-04-15 20:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# TODO: change to app-arch/bzip2[static-libs,shared] and build static-bin
# TODO: fix path install: /share -> /usr/share

# http://data.gpo.zugaina.org/gentoo/games-simulation/simutrans/simutrans-124.2.1.ebuild
# sample/ports-bug/games-simulation/simutrans_0.120.2.2_x32/simutrans_bug.md

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="A free Transport Tycoon clone (c++)"
HOMEPAGE="https://www.simutrans.com/"
LICENSE="Artistic"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PV="124-2-1"
XPV=${PV//-/.}  # no-posix
SVN_REVISION="11366"
SRC_URI="
  https://downloads.sourceforge.net/simutrans/${PN}-src-${PV}.zip
  https://downloads.sourceforge.net/simutrans/simupak64-${PV%-*}.zip -> simutrans_simupak64-${PV%-*}.zip
  https://tastytea.de/files/gentoo/simutrans_language_pack-Base+texts-${XPV}.zip
  http://data.gpo.zugaina.org/gentoo/games-simulation/${PN}/files/${PN}-124.0-disable-svn-check.patch
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
IUSE="-minimal -midi +fontconfig -upnp -zstd -static +shared -doc (+musl) +stest +strip"
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
ZCOMP="unzip"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/trunk"
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
  "app-arch/bzip2  # TODO: add static-libs" \
  "dev-libs/expat  # for freetype" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib  # deps sdl2" \
  "media-libs/freetype" \
  "media-libs/fontconfig" \
  "media-libs/libpng" \
  "media-libs/sdl2  # sdl2[sound,video]" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-libs/musl0" \
  "sys-libs/zlib  # deps libpng" \
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

  inherit desktop toolchain-funcs xdg install-functions

  cd "${WORKDIR}/" || die "builddir: not found... error"

  unzip -q "${FILESDIR}/simutrans-src-${PV}.zip"
  cd trunk/simutrans || die "could not cd to `simutrans`"
  use 'minimal' || unzip -q "${FILESDIR}/simutrans_simupak64-${PV%-*}.zip"

  # Bundled text files are incomplete, bug #580948
  cd text || die "could not cd to `simutrans/text`"
  unzip -q -o "${FILESDIR}/simutrans_language_pack-Base+texts-${XPV}.zip"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  if use !shared && use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-ldflags "-s -static --static"
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  append-cxxflags -std=gnu++14
  append-flags -fno-strict-aliasing  #859229

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  gpatch -p1 -E < "${FILESDIR}"/${PN}-124.0-disable-svn-check.patch

# NOTE: some flags need to be 0, some need to be empty to turn them off
cat > config.default <<-EOF || die
BACKEND=sdl2
OSTYPE=linux
OPTIMISE=0
STATIC=0
WITH_REVISION=${SVN_REVISION}
MULTI_THREAD=1
USE_UPNP=$(usex 'upnp' 1 '')
USE_FREETYPE=1
USE_ZSTD=$(usex 'zstd' 1 '')
USE_FONTCONFIG=$(usex 'fontconfig' 1 '')
USE_FLUIDSYNTH_MIDI=$(usex 'midi' 1 '')
VERBOSE=1

HOSTCC = ${CC}
HOSTCXX = ${CXX}
EOF

  make -j "$(nproc)" || die "Failed make build"

  mkdir -pm 0755 -- "${ED}"/bin/
  mv -v -n build/default/sim -T "${ED}"/bin/${PN} || die
  insinto usr/share/${PN}
  doins -r simutrans/*
  doicon src/simutrans/${PN}.svg
  domenu src/linux/simutrans.desktop

  cd "${ED}/" || die "install dir: not found... error"

  use 'strip' && strip --verbose --strip-all "bin/${PN}"

  use 'stest' && { bin/${PN} --version || : die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${XPV} pkg-create-cgz