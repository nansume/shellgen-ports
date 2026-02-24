#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# -------------------------------------------------
# Copyright (C) 2024-2026 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# -------------------------------------------------
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Description: Linux-VServer admin utilities
# Homepage: http://www.nongnu.org/util-vserver/
# License: GPL-2
# Depends: <deps>
# Date: 2024-09-27 09:00 UTC, 2026-02-04 15:00 UTC - last change
# Build with useflag: +static +static-libs -shared -lfs +nopie +patch -doc -xstub +diet -musl +stest +strip +amd64

# http://data.gpo.zugaina.org/KBrown-pub/sys-cluster/util-vserver/util-vserver-0.30.216_pre3131-r2.ebuild

# BUG[x32]: build with dietlibc-x32 - Failed
# TIP: now only build with dietlibc-amd64 or dietlibc-x86, with musl not tested

DOCS="README ChangeLog NEWS AUTHORS THANKS util-vserver.spec"
XPWD=${XPWD:-$PWD}; XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"; PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="0.30.216-pre3131"
PROG="sbin/vserver-info"; PROG=$(printf %s "${PROG}" | sed 's| |\t|g')
SRC_URI="
  http://people.linux-vserver.org/~dhozac/t/uv-testing/${PN}-${PV}.tar.xz
  http://data.gpo.zugaina.org/KBrown-pub/sys-cluster/${PN}/files/${PN}-0.30.216_pre3131-dietlibc.patch
  http://data.gpo.zugaina.org/KBrown-pub/sys-cluster/util-vserver/files/util-vserver-install-paths.patch
"
USE_BUILD_ROOT="0"; USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
BUILD_CHROOT=${BUILD_CHROOT:-0}; BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
SRC_DIR="build"
IUSE="-beecrypt +dietlibc +diet -nss +static +static-libs -shared +doc +stest +strip"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
EPREFIX="/"
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
DIETHOME="/opt/diet"
DIET="diet"

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
  "#dev-libs/beecrypt  # beecrypt (optional)" \
  "#dev-libs/nss  # nss (optional)" \
  "dev-util/ctags" \
  "dev-util/pkgconf" \
  "net-firewall/iptables" \
  "#net-misc/vconfig  # no needed, busybox have it" \
  "sys-apps/file" \
  "sys-apps/iproute2" \
  "sys-apps/net-tools" \
  "sys-devel/binutils9" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-fs/e2fsprogs  # needed headers: ext2_fs.h" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'diet' && pkginst "dev-libs/dietlibc # needed install after linux-headers"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  use '_diet' && {
  cp -nlr usr/include/asm-generic         -t opt/diet/include/
  cp -nl  usr/include/asm/*.h             -t opt/diet/include/asm/
  cp -nl  usr/include/asm/unistd*.h       -t opt/diet/include/asm/
  cp -nl  usr/include/linux/*.h           -t opt/diet/include/linux/
  cp -nl  usr/include/linux/capability.h  -t opt/diet/include/linux/
  cp -nl  usr/include/linux/fs.h          -t opt/diet/include/linux/
  cp -nl  usr/include/linux/personality.h -t opt/diet/include/linux/
  cp -nlr usr/include/bits                -t opt/diet/include/
  cp -nlr usr/include/ext2fs              -t opt/diet/include/
  cp -nl  usr/include/syscall.h           -t opt/diet/include/
  cp -nl  usr/include/wait.h              -t opt/diet/include/
  }
  sw-user || die "Failed package build from user... error"  # only for user-build
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  export VDIRBASE="/var/lib/vservers"

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -Os
  append-ldflags -Wl,--gc-sections -s -static --static
  append-cflags -ffunction-sections -fdata-sections
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  if use 'diet'; then
    #CFLAGS="${CFLAGS} -I/opt/diet/include -I/usr/include/linux"

    CC="diet -Os gcc -nostdinc -I/usr/include"

    PATH="${PATH:+${PATH}:}/opt/diet/bin"
  else
    CC="gcc"

    unset DIETHOME DIET
  fi

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  use 'diet' && patch -p1 -E < "${FILESDIR}/${PN}-0.30.216_pre3131-dietlibc.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-install-paths.patch"

  VDIRBASE=${VDIRBASE} \
  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --sbindir="${EPREFIX%/}/sbin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --libexecdir="${EPREFIX%/}"/usr/libexec \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    $(usex 'diet' --host=$(tc-chost | sed 's/-dietlibc/-musl/') ) \
    $(usex 'diet' --build=$(tc-chost | sed 's/-dietlibc/-musl/') ) \
    --with-vrootdir="${VDIRBASE}" \
    --with-initscripts=gentoo \
    --localstatedir=/var \
    $(usex 'diet' --enable-dietlibc) \
    --with-crypto-api=none \
    --disable-systemd \
    --disable-shared \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  sed -e 's/#define HAVE_DECL_MS_MOVE .*/#define HAVE_DECL_MS_MOVE 1/' -i config.h

  make -j1 || die "Failed make build"
  usleep 200000  # 0.2s

  make DESTDIR="${ED}" install-strip install-distribution || die "make install... error"

  # remove runtime paths
  rm -r "${ED}"/var/run "${ED}"/var/cache

  # bash-completion
  : newbashcomp "${FILESDIR}"/bash_completion ${PN}

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -r -- usr/share/man/

  find "$(get_libdir)/" -name '*.la' -delete || die

  # keep dirs
  > "${VDIRBASE#/}"/.pkg/.keepdir

  LD_LIBRARY_PATH=
  use 'stest' && { ${PROG} --version || die "binary work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

ldd "${PROG}" || { use 'static' && true || die "library deps work... error";}

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz