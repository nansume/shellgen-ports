#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2024-11-15 12:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-libs/redland/redland-1.0.17-r3.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="High-level interface for the Resource Description Framework"
HOMEPAGE="https://librdf.org/"
LICENSE="Apache-2.0 GPL-2 LGPL-2.1"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="1.0.17"
SRC_URI="
  https://download.librdf.org/source/${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/dev-libs/redland/files/redland-1.0.17-mysql-8-my_bool.patch
  http://data.gpo.zugaina.org/gentoo/dev-libs/redland/files/redland-1.0.17-ldflags-pc-leak.patch
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
IUSE="+berkdb -iodbc -mysql -odbc -postgres -sqlite -static-libs +shared -doc (+musl) +stest +strip"
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
PROG="rdfproc"

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
  "dev-db/bdb5  # optional" \
  "dev-libs/gmp  # deps: raptor,rasqal" \
  "dev-libs/icu64" \
  "dev-libs/libtasn1  # deps: raptor" \
  "dev-libs/libunistring  # deps: raptor" \
  "dev-libs/libxml2-1  # deps: raptor" \
  "dev-libs/libxslt  # deps: raptor" \
  "dev-libs/nettle  # deps: raptor" \
  "dev-libs/rasqal  # BUG: not found" \
  "dev-libs/openssl3  # deps: raptor" \
  "dev-util/byacc  # alternative a bison" \
  "dev-util/pkgconf" \
  "media-libs/raptor" \
  "net-misc/curl0" \
  "net-dns/c-ares  # deps: raptor" \
  "net-libs/gnutls  # deps: raptor" \
  "sys-apps/file" \
  "sys-apps/util-linux  # for libuuid" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/lex  # alternative a flex" \
  "sys-devel/libtool  # required for libltdl" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps: raptor" \
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

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-mysql-8-my_bool.patch
  # bug 468298
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-ldflags-pc-leak.patch

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
    --with-bdb-include="${INCDIR}" \
    --with-bdb-lib="${EPREFIX%/}"/$(get_libdir) \
    --with-bdb-dbname="${EPREFIX%/}"/$(get_libdir) \
    --cache-file="${BUILD_DIR}"/config.cache \
    $(use_with 'berkdb' bdb) \
    $(use_with 'mysql') \
    $(use_with 'sqlite') \
    $(use_with 'postgres' postgresql) \
    --without-threads \
    --with-html-dir="${EPREFIX%/}"/usr/share/gtk-doc/html/ \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    --disable-nls \
    --disable-rpath \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || : die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  find "$(get_libdir)/" -name '*.la' -delete || die

  use 'doc' || rm -vr -- "usr/share/gtk-doc/" "usr/share/man/"

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'stest' && { bin/${PROG} --version || : die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || : die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
