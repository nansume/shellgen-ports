#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-05-29 09:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/media-libs/libvpx/libvpx-1.14.1.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="WebM VP8 and VP9 Codec SDK"
HOMEPAGE="https://www.webmproject.org"
LICENSE="BSD"
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
PV="1.14.1"
SRC_URI="
  https://github.com/webmproject/${PN}/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/media-libs/libvpx/files/libvpx-1.13.1-allow-fortify-source.patch
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
IUSE="-cpu_flags_ppc_vsx3 -doc +highbitdepth -postproc +static-libs -test +threads"
IUSE="${IUSE} -svc -cpu_flags_x86_avx -cpu_flags_x86_avx2 -cpu_flags_x86_mmx +cpu_flags_x86_sse"
IUSE="${IUSE} -cpu_flags_x86_sse2 +cpu_flags_x86_sse3 -cpu_flags_x86_ssse3 -cpu_flags_x86_sse4_1"
IUSE="${IUSE} -xstub -nls -rpath +shared (+musl) (-debug) +stest -test +strip"
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
  "app-shells/bash  # FIX: busybox <od> no-compat" \
  "dev-lang/perl" \
  "dev-lang/yasm" \
  "sys-apps/coreutils  # FIX: busybox <od> no-compat" \
  "sys-apps/diffutils  # FIX: busybox <diff> no-compat" \
  "sys-devel/binutils" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
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

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  # od: unrecognized option: A - busybox nocompat
  # required fix

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

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # bug #501010
  patch -p1 -E < "${FILESDIR}/${PN}-1.13.1-allow-fortify-source.patch"

  # $(usex 'x32' --force-target=generic-gnu) \
  /bin/bash ./configure \
    --prefix="${EPREFIX%/}/usr" \
    --libdir="${EPREFIX%/}/usr/$(get_libdir)" \
    --enable-pic \
    --enable-vp8 \
    --enable-vp9 \
    --disable-optimizations \
    $(use_enable 'postproc') \
    $(use_enable 'test' unit-tests) \
    $(use_enable 'threads' multithread) \
    $(use_enable 'highbitdepth' vp9-highbitdepth) \
    --extra-cflags="${CFLAGS}" \
    $(usex 'x86' --force-target=x86-linux-gcc) \
    $(usex 'amd64' --force-target=x86_64-linux-gcc) \
    $(usex 'x32' --force-target=x86_64-linux-gcc) \
    $(use_enable 'cpu_flags_x86_avx' avx) \
    $(use_enable 'cpu_flags_x86_avx2' avx2) \
    $(use_enable 'cpu_flags_x86_mmx' mmx) \
    $(use 'cpu_flags_x86_sse2' && use_enable 'cpu_flags_x86_sse' sse || printf --disable-sse) \
    $(use_enable 'cpu_flags_x86_sse2' sse2) \
    $(use_enable 'cpu_flags_x86_sse3' sse3) \
    $(use_enable 'cpu_flags_x86_sse4_1' sse4_1) \
    $(use_enable 'cpu_flags_x86_ssse3' ssse3) \
    --disable-examples \
    --disable-install-docs \
    --disable-docs \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc --ignore=1)" GEN_EXAMPLES= || die "Failed make build"

  # pkg install uses only --strip-debug
  . runverb \
  make GEN_EXAMPLES= DESTDIR="${ED}" install || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  mv -vn "usr/$(get_libdir)" .
  grep 'libdir=.*' < $(get_libdir)/pkgconfig/vpx.pc
  sed -i "4s|^libdir=.*|libdir=/$(get_libdir)|;t" $(get_libdir)/pkgconfig/"vpx.pc"

  # install uses strip <--strip-debug>, it safe.
  if use 'static-libs'; then
    strip --strip-unneeded "$(get_libdir)/"${PN}.a "$(get_libdir)/"${PN}.a.*
  fi
  strip --verbose --strip-all "$(get_libdir)/"${PN}.so "$(get_libdir)/"${PN}.so.*

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz