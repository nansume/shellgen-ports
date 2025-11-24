#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-05-31 16:00 UTC, 2025-06-14 19:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sys-libs/libblockdev/libblockdev-3.1.1-r1.ebuild

# BUG: then build with `--with-tools` we get a error is here. (install phase)

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="A library for manipulating block devices"
HOMEPAGE="https://github.com/storaged-project/libblockdev"
LICENSE="LGPL-2+"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
PV="3.1.1"
SPV="${PV}-1"
SLOT="3"  # subslot is SOVERSION
BASE_URI="data.gpo.zugaina.org/gentoo/sys-libs/libblockdev/files"
SRC_URI="
  https://github.com/storaged-project/${PN}/releases/download/${SPV}/${PN}-${PV}.tar.gz
  http://${BASE_URI}/libblockdev-3.0.4-add-non-systemd-method-for-distro-info.patch
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
IUSE="+cryptsetup +device-mapper -escrow -gtk-doc +introspection +lvm -nvme -test -tools"
IUSE="${IUSE} -static +static-libs +shared -doc (+musl) +stest +strip"
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
  "app-shells/bash  # for install" \
  "dev-build/autoconf-archive" \
  "dev-build/autoconf71  # required for autotools" \
  "dev-build/automake16  # required for autotools" \
  "dev-build/libtool6  # required for autotools,libtoolize" \
  "dev-lang/perl  # required for autotools" \
  "dev-lang/python3-8" \
  "dev-libs/expat  # deps python" \
  "dev-libs/glib74" \
  "dev-libs/gmp  # deps libbytesize,cryptsetup" \
  "dev-libs/gobject-introspection74  # introspection?" \
  "dev-libs/json-c  # deps cryptsetup" \
  "dev-libs/libaio  # deps cryptsetup" \
  "dev-libs/libbytesize" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/mpfr  # deps libbytesize" \
  "dev-libs/pcre2  # for glib74" \
  "dev-libs/popt  # deps cryptsetup" \
  "dev-libs/openssl3  # deps cryptsetup" \
  "dev-util/pkgconf" \
  "sys-apps/coreutils" \
  "sys-apps/file" \
  "sys-apps/gptfdisk" \
  "sys-apps/kmod  # deps udev" \
  "sys-apps/keyutils  # for cryptsetup" \
  "#sys-apps/lsb-release  # it missing" \
  "sys-apps/util-linux  # deps udev" \
  "sys-block/parted  # tools?" \
  "#sys-block/targetcli-fb  # it missing (for test)" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-fs/cryptsetup  # required" \
  "sys-fs/e2fsprogs" \
  "sys-fs/eudev" \
  "sys-fs/lvm2  # deps cryptsetup" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib  # for glib" \
  || die "Failed install build pkg depend... error"

USE="${USE} -dbus"

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

  patch -p1 -E < "${FILESDIR}"/libblockdev-3.0.4-add-non-systemd-method-for-distro-info.patch

  # https://bugs.gentoo.org/744289
  find -type f \( -name "Makefile.am" -o -name "configure.ac" \) -print0 \
   | xargs -0 sed "s@ -Werror@@" -i || die

  test -x "/bin/perl" && autoreconf

  /bin/bash \
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
    --without-btrfs \
    --with-fs \
    --with-part \
    --without-python3 \
    --without-mpath \
    --without-nvdimm \
    $(use_enable 'introspection') \
    $(use_enable 'test' tests) \
    $(use_with 'cryptsetup' crypto) \
    $(use_with 'device-mapper' dm) \
    $(use_with 'escrow') \
    $(use_with 'gtk-doc') \
    $(use_with 'lvm' lvm) \
    $(use_with 'dbus' lvm-dbus) \
    $(use_with 'nvme') \
    $(use_with 'tools') \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  # then build with `--with-tools` we get a error is here. (install phase)
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  find "$(get_libdir)/" -type f -name "*.la" -delete || die

  # This is installed even with USE=-lvm, but libbd_lvm are omitted so it
  # doesn't work at all.
  if ! use 'lvm'; then
    [ -x "bin/lvm-cache-stats" ] && rm -- "${ED}"/bin/lvm-cache-stats
  fi
  : python_optimize  #718576

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  ldd "$(get_libdir)"/${PN}.so.3.0.0 || die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz