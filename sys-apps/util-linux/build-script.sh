#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2023-11-22 20:00 UTC, 2025-06-14 16:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sys-apps/util-linux/util-linux-2.41.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Various useful Linux utilities"
HOMEPAGE="https://www.kernel.org/pub/linux/utils/util-linux/ https://github.com/util-linux/util-linux"
LICENSE="GPL-2 GPL-3 LGPL-2.1 BSD-4 MIT public-domain"
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
PV="2.37.2"
SRC_URI="
  https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v${PV%.*}/${PN}-${PV}.tar.xz
  http://loop-aes.sourceforge.net/updates/util-linux-${PV%.*}-20210620.diff.bz2
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
IUSE="-audit -build -caps -cramfs -cryptsetup -fdformat -hardlink -kill -logger"
IUSE="${IUSE} -magic -ncurses -nls -pam -python -readline -rtas -selinux -slang"
IUSE="${IUSE} +static-libs -su -suid -systemd -test -tty-helpers -udev -unicode"
IUSE="${IUSE} -uuidd +static +shared -doc (+musl) +stest +strip"
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
PROG="switch_root"

#FFLAGS='-O2 -msse2 -fno-stack-protector -g0'
#CPU_NUM=$(cpucore-num)
#IONICE_COMM='nice -n 19'
#XLDFLAGS=

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
  "dev-build/autoconf71  # slot=71,slot=69 - required for autotools" \
  "dev-build/automake16  # slot=16,slot=15 - required for autotools" \
  "dev-lang/perl  # required for autotools" \
  "dev-util/pkgconf" \
  "sys-apps/file" \
  "sys-devel/binutils6" \
  "sys-devel/bison" \
  "sys-devel/gcc6" \
  "sys-devel/gettext  # required for autotools (optional)" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

USE="${USE} +static +static-libs"

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
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  bunzip2 -dc "${FILESDIR}/${PN}-${PV%.${PV#*.*.}}-20210620.diff.bz2" | patch -p1 -E

  test -x "/bin/perl" && autoreconf

  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-all-programs \
    --disable-agetty \
    --disable-asciidoc \
    --disable-bash-completion \
    --disable-bfs \
    --without-btrfs \
    --disable-chfn-chsh \
    --disable-cramfs \
    --disable-eject \
    --disable-fallocate \
    --disable-fsck \
    --disable-fstrim \
    --disable-gtk-doc \
    --disable-hwclock \
    --disable-makeinstall-chown \
    --disable-makeinstall-setuid \
    --disable-mesg \
    --disable-minix \
    --disable-mountpoint \
    --without-ncurses \
    --without-ncursesw \
    --disable-nologin \
    --disable-partx \
    --disable-pivot_root \
    --disable-plymouth_support \
    --disable-pylibmount \
    --without-python \
    --disable-raw \
    --disable-rfkill \
    --disable-setpriv \
    --disable-swapon \
    --without-systemd \
    --disable-tls \
    --disable-use-tty-group \
    --disable-unshare \
    --disable-utmpdump \
    --disable-widechar \
    --disable-whereis \
    --disable-wipefs \
    --disable-zramctl \
    --without-udev \
    --disable-blkid \
    --enable-losetup \
    --enable-libuuid \
    --enable-libblkid \
    --enable-libfdisk \
    --enable-libmount \
    --disable-switch_root \
    --enable-libsmartcols \
    --enable-static-programs="losetup" \
    $(use_enable 'rpath') \
    $(use_enable 'nls') \
    $(use_enable 'shared') \
    --enable-static \
    || die "configure... error"

  make -j "$(nproc --ignore=1)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  #######################################################

  CFLAGS=${CFLAGS/-O?/-Os}
  CXXFLAGS=${CXXFLAGS/-O?/-Os}

  append-flags -Os
  append-ldflags -Wl,--gc-sections
  append-cflags -ffunction-sections -fdata-sections
  append-ldflags "-s -static --static"

  ./configure --disable-all-programs --without-btrfs --enable-switch_root || die "configure... error"
  make -j "$(nproc --ignore=1)" switch_root || die "Failed make <switch_root> build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install: switch_root... error"
  #######################################################

  cd "${ED}/" || die "install dir: not found... error"

  if test -x 'sbin/losetup'; then
    rm -- sbin/losetup
    mv -vn bin/losetup.static sbin/loop-aes-losetup
    ln -sf loop-aes-losetup sbin/losetup
  fi

  rm -v -r -- "bin/" "usr/bin/" "usr/lib/" "usr/sbin/" "usr/share/bash-completion/"

  use 'doc' || rm -v -r -- "usr/share/man/" "usr/share/"

  find "$(get_libdir)/" -name "*.la" -delete || die

  use 'stest' && { sbin/${PROG} --version || die "binary work... error";}
  ldd "sbin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz