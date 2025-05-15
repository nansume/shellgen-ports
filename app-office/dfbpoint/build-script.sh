#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-04-15 13:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# sample/ports-bug/app-office/dfbpoint/dfbpoint_bug.md

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="DFBPoint - a presentation viewer using DirectFB"
HOMEPAGE=""
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
PN="DFBPoint"
PV="0.7.2"
PN2="glib"
PV2="2.24.2"
XPV2="${PV2%.*}"
SRC_URI="
  http://localhost/DFBPoint-${PV}.tar.gz
  https://download.gnome.org/sources/${PN2}/${XPV2}/${PN2}-${PV2}.tar.bz2
  #https://download.gnome.org/sources/${PN2}/${XPV2}/${PN2}-${PV2}.tar.xz
  http://data.gpo.zugaina.org/didos/dev-libs/glib/files/2.56.2-quark_init_on_demand.patch
  http://data.gpo.zugaina.org/didos/dev-libs/glib/files/2.56.2-gobject_init_on_demand.patch
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
IUSE="-static +shared -doc (+musl) +stest +strip"
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
PROG=${XPN}

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
  "dev-libs/directfb" \
  "dev-libs/libffi  # deps glib" \
  "#dev-libs/glib57" \
  "dev-util/pkgconf" \
  "media-libs/libpng  # deps directfb" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/gettext-tiny  # required for autotools (optional)" \
  "sys-devel/libtool  # required for autotools,libtoolize" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl  # deps glib: optional (too recomended)" \
  "sys-libs/musl0" \
  "sys-libs/zlib  # deps directfb,glib" \
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

  for PF in *.tar.gz *.tar.bz2; do
    case ${PF} in
      '*'.tar.*) continue;;
      *.tar.gz)  ZCOMP="gunzip";;
      *.tar.bz2) ZCOMP="bunzip2";;
    esac
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  #############################################################################

  cd "${WORKDIR}/${PN2}-${PV2}/" || die "builddir: not found... error"

  PYTHON="true" \
  ./configure \
    --prefix="${EPREFIX%/}/usr" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-gtk-doc-html \
    --disable-fam \
    --disable-gtk-doc \
    --disable-libmount \
    --disable-man \
    --disable-xattr \
    --with-threads=posix \
    --disable-libelf \
    --disable-compile-warnings \
    --with-pcre="internal" \
    --enable-static \
    --disable-shared \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"
  make DESTDIR="${BUILD_DIR}/${PN2}" install || die "make install... error"

  [ -f "${BUILD_DIR}/${PN2}/$(get_libdir)/$(get_libdir)/libglib-2.0.a" ] &&
  ln -vs libglib-2.0.a "${BUILD_DIR}/${PN2}/$(get_libdir)/$(get_libdir)/"libglib.a

  CFLAGS="${CFLAGS} -I${BUILD_DIR}/${PN2}/${INCDIR#/}/${PN2} -I${BUILD_DIR}/${PN2}/${INCDIR#/}/glib-2.0"
  CFLAGS="${CFLAGS} -I${BUILD_DIR}/${PN2}/$(get_libdir)/glib-2.0/include"
  LDFLAGS="${LDFLAGS} -Wl,-Bstatic -L${BUILD_DIR}/${PN2}/$(get_libdir) -lglib-2.0 -Wl,-Bdynamic"
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${BUILD_DIR}/${PN2}/lib/pkgconfig"
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${BUILD_DIR}/${PN2}/$(get_libdir)/pkgconfig"

  sed \
    -e "s|^libdir=.*|libdir=${BUILD_DIR}/${PN2}/$(get_libdir)|" \
    -e "s|^includedir=.*|includedir=${BUILD_DIR}/${PN2}/usr/include|" \
    -i ${BUILD_DIR}/${PN2}/$(get_libdir)/pkgconfig/*.pc

  #############################################################################

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-glibtest \
    --enable-static \
    --disable-shared \
    --disable-nls \
    --disable-rpath \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'stest' && { bin/${PROG} --version || die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz