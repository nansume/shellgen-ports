#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-10-04 19:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# dietlibc support, is no needed, use only how bundled for other packages.

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Standard EXT2/EXT3/EXT4 filesystem utilities"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
LICENSE="GPL-2 BSD"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="1.46.4"
PV="1.47.0"
PV="1.47.1"
SRC_URI="http://data.gpo.zugaina.org/gentoo/sys-fs/e2fsprogs"
SRC_URI="
  https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v${PV}/e2fsprogs-${PV}.tar.xz
  #ftp://mirrors.tera-byte.com/pub/gentoo/distfiles/e2fsprogs-1.46.4.tar.xz
  ${SRC_URI}/files/${PN}-1.42.13-fix-build-cflags.patch
  ${SRC_URI}/files/${PN}-1.47.0-disable-metadata_csum_seed-and-orphan_file-by-default.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-static -static-libs +shared -doc (+musl) +stest +strip"
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
  "#app-alternatives/libblkid" \
  "dev-lang/perl  # required for texinfo" \
  "dev-util/pkgconf" \
  "sys-apps/texinfo  # optional, no is bug install" \
  "sys-apps/util-linux" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "#sys-fs/e2fsprogs-libs" \
  "sys-kernel/linux-headers-musl" \
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

  CC="gcc"

  # needed for >=musl-1.2.4, bug 908892
  use 'musl' && append-cflags -D_FILE_OFFSET_BITS=64

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/${PN}-1.42.13-fix-build-cflags.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-1.47.0-disable-metadata_csum_seed-and-orphan_file-by-default.patch

  rm -r doc || die "Failed to remove doc dir"

  export ac_cv_lib_uuid_uuid_generate=yes
  export ac_cv_lib_blkid_blkid_get_cache=yes

  ac_cv_path_LDCONFIG=: \
  CC="${CC}" \
  BUILD_CC="${CC}" \
  ./configure \
    --with-root-prefix="${EPREFIX%/}" \
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
    $(usex 'fuse' --enable-fuse) \
    --enable-elf-shlibs \
    --enable-symlink-install \
    --disable-tls \
    $(usex 'musl' --enable-largefile) \
    --disable-debugfs \
    --disable-defrag \
    --disable-e2initrd-helper \
    --disable-fsck \
    --disable-imager \
    --disable-libblkid \
    --disable-libuuid \
    --disable-resizer \
    --disable-testio-debug \
    --disable-uuidd \
    --disable-lto \
    --with-pthread \
    $(use_enable 'nls') \
    $(use_enable 'rpath') \
    || die "configure... error"

  # Parallel make issue #936493
  make -j "$(nproc)" -C lib/et V=1 compile_et || die "Failed lib/et make build"
  make -j "$(nproc)" -C lib/ext2fs V=1 ext2_err.h || die "Failed lib/ext2fs make build"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" install || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  # configure doesn't have an option to disable static libs
  if ! use 'static-libs'; then
    find "$(get_libdir)/" -name '*.a' -delete || die
  fi

  strip --verbose --strip-all "bin/"chattr "bin/"lsattr "$(get_libdir)/"lib*.so.*.*
  strip --verbose --strip-all "sbin/"badblocks "sbin/"dumpe2fs "sbin/"e2freefrag "sbin/"e2fsck
  strip --verbose --strip-all "sbin/"e2undo "sbin/"e4crypt "sbin/"filefrag "sbin/"logsave
  strip --verbose --strip-all "sbin/"mke2fs "sbin/"mklost+found "sbin/"tune2fs

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
