#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-04-13 10:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# BUG: not found: libjpeg.la (build with gd jpeg flags)

# https://git.alpinelinux.org/aports/plain/community/libgphoto2/APKBUILD
# http://data.gpo.zugaina.org/gentoo/media-libs/libgphoto2/libgphoto2-2.5.31-r2.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX _CPP PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH _LIBS _LDCONFIG

DESCRIPTION="Library that implements support for numerous digital cameras"
HOMEPAGE="http://www.gphoto.org/"
LICENSE="GPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
#PN=${PN%[0-9]}
PV="2.5.31"
SLOT="2"  # SLOT=`0/6` libgphoto2.so soname version
SRC_URI="https://downloads.sourceforge.net/gphoto/${PN}-${PV}.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-doc -examples +exif -gd -jpeg -nls -serial +static-libs +shared (+musl) +stest +strip"
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
ZCOMP="unxz"
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
PROG="$(get_libdir)/${PN}/print-camera-list"

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
  "#dev-libs/expat  # deps libgd" \
  "dev-libs/gmp  # deps ssl" \
  "dev-libs/libusb" \
  "dev-libs/libxml2-1" \
  "dev-libs/openssl3  # deps curl" \
  "dev-util/pkgconf" \
  "#media-libs/fontconfig  # deps libgd" \
  "#media-libs/freetype  # deps libgd" \
  "#media-libs/gd  # required libjpeg.la" \
  "media-libs/libexif" \
  "#media-libs/libjpeg-turbo3" \
  "#media-libs/libpng  # deps libgd" \
  "#media-libs/libwebp  # deps libgd" \
  "#media-libs/tiff  # deps libgd" \
  "net-dns/c-ares  # adns?" \
  "net-misc/curl8-2" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/lex  # alternative a flex (posix)" \
  "sys-devel/libtool  # required for libltdl" \
  "sys-devel/make" \
  "sys-libs/musl0" \
  "sys-libs/zlib  # deps: openssl,curl,libpng" \
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

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --with-drivers=all \
    $(use_with 'exif' libexif auto) \
    --without-gd \
    --without-jpeg \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    --disable-nls \
    --disable-rpath \
    udevscriptdir="/lib/udev" \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -v -r -- usr/share/doc/ usr/share/man/

  find "$(get_libdir)/" -name '*.la' -delete || die

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"

  use 'stest' && { ${PROG} --help || die "binary work... error";}
  ldd "$(get_libdir)/${PN}.so" || die "library deps work... error"

  mkdir -pm 0755 -- "lib/udev/rules.d/"

  CAMLIBS="${ED}/$(get_libdir)/${PN}/${PV}" \
  ${PROG} udev-rules version 136 group camera mode 0660 > "lib/udev/rules.d/54-gphoto.rules"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz