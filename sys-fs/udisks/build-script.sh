#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-05-31 18:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sys-fs/udisks/udisks-2.10.1-r3.ebuild

# BUG: with +daemon - udiskslinuxblock.c error: implicit declaration of function <bd_crypto_luks_uuid>
# TODO: rebuild dev-libs/libgudev with new deps

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Daemon providing interfaces to work with storage devices"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/udisks"
LICENSE="LGPL-2+ GPL-2+"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PV="2.10.1"  # BUG: required libblockdev3[nvme]
PV="2.9.4"
SRC_URI="
  https://github.com/storaged-project/udisks/releases/download/${PN}-${PV}/${PN}-${PV}.tar.bz2
  #http://data.gpo.zugaina.org/gentoo/sys-fs/udisks/files/${PN}-${PV}-BLKRRPART_harder.patch
  #http://data.gpo.zugaina.org/gentoo/sys-fs/udisks/files/${PN}-${PV}-targetcli_config.json_netif_timeout.patch
  #http://data.gpo.zugaina.org/gentoo/sys-fs/udisks/files/${PN}-${PV}-udiskslinuxmanager_use_after_free.patch
  #http://data.gpo.zugaina.org/gentoo/sys-fs/udisks/files/${PN}-${PV}-udiskslinuxblock_survive_missing_fstab.patch
  #http://data.gpo.zugaina.org/gentoo/sys-fs/udisks/files/${PN}-2.10.1-slibtool-export-dynamic.patch
  http://data.gpo.zugaina.org/gentoo/sys-fs/udisks/files/${PN}-2.9.4-undefined.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-acl -daemon -debug +elogind +introspection +lvm -nls -selinux -systemd -vdo -zram"
IUSE="${IUSE} +static-libs +shared -doc (+musl) +stest +strip"
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
ZCOMP="bunzip2"
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
PROG="udisksctl"

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
  "sys-apps/coreutils" \
  "dev-build/autoconf-archive" \
  "dev-build/autoconf71  # slot=71,slot=69 - required for autotools" \
  "dev-build/automake16  # slot=16,slot=15 - required for autotools" \
  "dev-build/libtool9  # required for autotools,libtoolize" \
  "dev-lang/duktape  # deps polkit" \
  "dev-lang/perl  # required for autotools" \
  "dev-lang/python3-8" \
  "dev-libs/expat  # deps python" \
  "dev-libs/glib74" \
  "dev-libs/gmp  # deps libblockdev" \
  "dev-libs/gobject-introspection74" \
  "dev-libs/json-c  # deps libblockdev" \
  "dev-libs/libaio  # deps libblockdev" \
  "dev-libs/libatasmart  # daemon?" \
  "dev-libs/libbytesize  # deps libblockdev" \
  "dev-libs/libffi  # deps glib" \
  "dev-libs/libgudev  # daemon?" \
  "#dev-libs/libxslt  # ?deps polkit" \
  "dev-libs/mpfr  # deps libblockdev" \
  "dev-libs/pcre2  # deps glib74" \
  "dev-libs/popt  # deps libblockdev" \
  "dev-libs/openssl3  # deps libblockdev" \
  "dev-util/pkgconf" \
  "sys-apps/dbus  # deps polkit" \
  "sys-apps/file" \
  "sys-apps/gptfdisk  # ?deps libblockdev" \
  "sys-apps/keyutils  # deps libblockdev" \
  "sys-apps/kmod  # deps udev" \
  "sys-apps/util-linux  # deps udev" \
  "sys-auth/elogind  # deps polkit" \
  "sys-auth/polkit" \
  "sys-block/parted" \
  "sys-devel/binutils9" \
  "sys-devel/gcc9" \
  "sys-devel/gettext-tiny  # required for autotools (optional)" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-fs/cryptsetup  # deps libblockdev" \
  "sys-fs/e2fsprogs  # deps libblockdev" \
  "sys-fs/eudev" \
  "sys-fs/lvm2" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/libcap  # deps polkit" \
  "sys-libs/libblockdev3" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps glib" \
  "x11-libs/libx11  # deps polkit" \
  "x11-libs/libxau  # deps polkit" \
  "x11-libs/libxcb  # deps polkit" \
  "x11-libs/libxdmcp  # deps polkit" \
  "x11-libs/libxt  # deps polkit" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  printf '#!/bin/sh' > /bin/xutils-stub
  chmod +x /bin/xutils-stub
  ln -sf xutils-stub /bin/gtkdocize
  ln -sf xutils-stub /bin/path
fi

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

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # ver: 2.10.1
  #patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-BLKRRPART_harder.patch
  #patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-targetcli_config.json_netif_timeout.patch
  #patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-udiskslinuxmanager_use_after_free.patch
  #patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-udiskslinuxblock_survive_missing_fstab.patch
  #patch -p1 -E < "${FILESDIR}"/${PN}-2.10.1-slibtool-export-dynamic.patch

  # ver: 2.9.4
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-undefined.patch  # ver: 2.9.4

  sed -e 's:libsystemd-login:&disable:' -i configure || die

  # Added for bug # 782061
  test -x "/bin/perl" && autoreconf -i

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
    --localstatedir="${EPREFIX%/}"/var \
    --with-html-dir="${EPREFIX%/}"/usr/share/gtk-doc/html \
    --with-modprobedir="${EPREFIX%/}"/lib/modprobe.d \
    --with-systemdsystemunitdir=/lib/systemd/systemd \
    --with-tmpfilesdir="${EPREFIX%/}"/lib/tmpfiles.d \
    --with-udevdir="${EPREFIX%/}"/lib/udev \
    --disable-btrfs \
    --disable-gtk-doc \
    --disable-man \
    $(use_enable 'acl') \
    $(use_enable 'daemon') \
    $(use_enable 'debug') \
    $(use_enable 'introspection') \
    $(use_enable 'lvm' lvm2) \
    $(use_enable 'lvm' lvmcache) \
    $(use_enable 'vdo') \
    $(use_enable 'zram') \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    --disable-nls \
    --disable-rpath \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  # FIX: coreutils: cannot stat './udisksctl.1': No such file or directory
  > doc/man/udisksctl.1

  make DESTDIR="${ED}" install || die "make install... error"

  : keepdir /var/lib/udisks2  #383091

  rm -r -- "${ED}"/usr/share/bash-completion/
  : dobashcomp data/completions/udisksctl

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -v -r -- "usr/share/doc/" "usr/share/man/"

  find "$(get_libdir)/" -type f -name "*.la" -delete || die

  use 'shared' && strip --verbose --strip-all "bin/"* "$(get_libdir)/"lib${PN}2.so.0.0.0
  use 'static-libs' && strip --strip-unneeded "$(get_libdir)/"lib${PN}2.a

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'stest' && { bin/${PROG} --help || : die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz