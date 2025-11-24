#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2023, 2024-04-17 21:00 UTC, 2025-06-09 21:00 UTC - last change
# Build with useflag: -static -static-libs +shared +ipv6 -lfs +nopie +patch -doc -xstub +musl +stest +strip +x32

# https://crux.nu/ports/crux-3.8/opt/nspr/Pkgfile

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="Netscape Portable Runtime"
HOMEPAGE="http://www.mozilla.org/projects/nspr/"
LICENSE="MPL-2.0 GPL-2 LGPL-2.1"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]*}
PV="4.35"  #nspr_4.21-r666_x32.cxz
PV="4.36"
SRC_URI="
  https://archive.mozilla.org/pub/nspr/releases/v${PV}/src/${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/dev-libs/${PN}/files/${PN}-4.21-ipv6-musl-support.patch
  http://data.gpo.zugaina.org/gentoo/dev-libs/${PN}/files/${PN}-4.35-bgo-905998-lfs64-musl.patch
  https://crux.nu/ports/crux-3.8/opt/nspr/nspr.pc.in
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
IUSE="+ipv6 -debug -static-libs +shared -doc (+musl) +stest -strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}/${PN}"
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

. "${PDIR%/}/etools.d/"build-functions  # add func utils: append-cflags

chroot-build || die "Failed chroot... error"

pkginst \
  "sys-devel/binutils" \
  "sys-devel/gcc6" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-libs/musl" \
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

  inherit build pkg-export build-functions autotools eutils toolchain-funcs versionator

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  case $(tc-chost) in
    *-"musl"*)
      gpatch -p1 -E < "${FILESDIR}/nspr-4.21-ipv6-musl-support.patch"
      gpatch -p1 -E < "${FILESDIR}/nspr-4.35-bgo-905998-lfs64-musl.patch"
    ;;
  esac

  #--enable-optimize=$(get-flag '-O*') \
  . runverb \
  ./configure \
    CC="${CC}" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="/usr/include/nspr" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'debug') \
    --enable-optimize="${CFLAGS}" \
    $(use 'x32' && use_enable 'x32') \
    $(use_enable 'strip') \
    $(use_enable 'ipv6') \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    $(test -n "${LDFLAGS}" && printf %s "LDFLAGS=${LDFLAGS}") \
    || die "configure... error"

  make -j "$(nproc --ignore=1)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" install || die "make install... error"

  export NSPR_LIBS=$(./config/nspr-config --libs)
  export NSPR_CFLAGS=$(./config/nspr-config --cflags)
  export NSPR_VERSION=$(./config/nspr-config --version)

  install -d "${ED}"/$(get_libdir)/pkgconfig

  cd "${ED}/" || die "install dir: not found... error"

  if use 'static-libs'; then
    chmod -x $(get_libdir)/*.a
  else
    rm -- $(get_libdir)/*.a || die "failed to remove static libraries."
  fi

  rm -- bin/prerr.properties bin/compile-et.pl || die
  rm -v -r -- "usr/include/nspr/md/"

  sed ${FILESDIR}/nspr.pc.in \
    -e "s,@libdir@,/$(get_libdir)," \
    -e "s,@prefix@,/usr," \
    -e "s,@exec_prefix@,/bin," \
    -e "s,@includedir@,/usr/include/nspr," \
    -e "s,@NSPR_VERSION@,${NSPR_VERSION}," \
    -e "s,@FULL_NSPR_LIBS@,${NSPR_LIBS}," \
    -e "s,@FULL_NSPR_CFLAGS@,${NSPR_CFLAGS}," \
    > ${ED}/$(get_libdir)/pkgconfig/nspr.pc

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz