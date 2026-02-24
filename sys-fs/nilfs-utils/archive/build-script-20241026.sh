#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-10-26 18:00 UTC - last change
# Build with useflag: +static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +amd64
# x32 buggy - nilfs_cleanerd: nowork

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Utilities for managing NILFS v2 filesystems"
HOMEPAGE="https://nilfs.sourceforge.net/"
LICENSE="GPL-2.0-or-later"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]*}
PV="2.2.11"
PV2="2.37.2"
PV2="2.40.2"
SRC_URI="
  https://github.com/nilfs-dev/${PN}/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz
  https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v${PV2%.*}/util-linux-${PV2}.tar.xz
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
IUSE="-nopic -blkid -libmount +static +static-libs +shared -doc (+musl) +stest +strip"
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
PROG="sbin/nilfs_cleanerd"

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
  "dev-lang/perl  # required for autotools" \
  "dev-util/byacc  # alternative a bison for util-linux bundled" \
  "dev-util/pkgconf  # required for util-linux bundled" \
  "sys-apps/file" \
  "#sys-apps/util-linux  # is bundled, now no needed it." \
  "sys-devel/autoconf  # required for autotools" \
  "sys-devel/automake  # required for autotools" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/libtool  # required for autotools" \
  "sys-devel/m4  # required for autotools (optional?)" \
  "sys-devel/make" \
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

  for PF in *.tar.gz *.tar.xz; do
    case ${PF} in *.tar.gz) ZCOMP="gunzip";; *.tar.xz) ZCOMP="unxz";; esac
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
    use 'static' && append-ldflags "-s -static --static"
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc$(usex static ' -static --static')"

  use 'strip' && INSTALL_OPTS="install-strip"

  use 'static' && {
  cd ${WORKDIR}/util-linux-*/ || die "builddir: not found... error"

  test -x "/bin/perl" && autoreconf

  ./configure \
    --prefix="${SPREFIX%/}" \
    --bindir="${SPREFIX%/}/bin" \
    --sbindir="${SPREFIX%/}/sbin" \
    --libdir="${SPREFIX%/}/${LIB_DIR}" \
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
    --enable-libuuid \
    --disable-libblkid \
    --disable-libmount \
    --disable-switch_root \
    --disable-libsmartcols \
    $(use_enable 'rpath') \
    $(use_enable 'nls') \
    $(use_enable 'shared') \
    --enable-static \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${BUILD_DIR}/util-linux" install || die "make install... error"

  CFLAGS="${CFLAGS} -I${BUILD_DIR}/util-linux/${INCDIR#/}"
  LDFLAGS="${LDFLAGS} -L${BUILD_DIR}/util-linux/$(get_libdir)"
  }

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  test -x "/bin/perl" && autoreconf -fi

  LDCONFIG=: \
  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --infodir="${EPREFIX%/}"/usr/share/info \
    --localstatedir=/var \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --without-blkid \
    --without-selinux \
    --without-libmount \
    --without-pic \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  sed \
    -e 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' \
    -e 's|^runpath_var=LD_RUN_PATH|runpath_var=DIE_RPATH_DIE|g' \
    -i libtool

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  rm -r -- "$(get_libdir)/" "usr/"

  use 'static' && LD_LIBRARY_PATH=
  use 'stest' && { ${PROG} --version || die "binary work... error";}
  ldd ${PROG} || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
