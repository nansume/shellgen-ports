#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-19 14:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Framework for defining and tracking users, login sessions and seats"
HOMEPAGE="https://github.com/ConsoleKit2/ConsoleKit2 https://www.freedesktop.org/wiki/Software/ConsoleKit/"
LICENSE="GPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN="ConsoleKit2"
PV="1.2.6"
PROG="sbin/console-kit-daemon"
KVER="5.8.9"
SRC_URI="https://github.com/${PN}/${PN}/archive/refs/tags/${PV}.tar.gz -> ${XPN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-acl -debug -doc -evdev -kernel_linux -pam -policykit -test -udev"
IUSE="${IUSE} -static-libs +shared (+musl) +stest +strip"
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
  "dev-lang/perl  # required for autotools" \
  "dev-lang/python3  # for glib codegen" \
  "dev-libs/expat  # deps python" \
  "dev-libs/glib  # required - glib[dbus]" \
  "dev-libs/pcre  # optional (pcre for glib-2.68)" \
  "#dev-libs/libevdev  # for <evdev>" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libxslt" \
  "#dev-util/byacc  # alternative a bison" \
  "dev-util/pkgconf" \
  "sys-apps/dbus" \
  "#sys-apps/acl  # optional <acl>" \
  "sys-apps/coreutils  # coreutils[acl] for <kernel_linux>" \
  "sys-apps/file" \
  "#sys-auth/polkit  # for <policykit>" \
  "sys-devel/autoconf  # required for autotools" \
  "sys-devel/automake  # required for autotools" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/gettext  # required for autotools (optional)" \
  "sys-devel/libtool  # required for autotools" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "#sys-fs/eudev  # optional - for: <acl>,<udev>" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/pam  # for <pam>" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  "x11-base/xorg-proto" \
  "x11-libs/libdrm  # for <udev>" \
  "x11-libs/libpciaccess  # deps libdrm" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxdmcp" \
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

  . "${PDIR%/}/etools.d/"epython

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

  CC="gcc"

  use 'strip' && INSTALL_OPTS="install-strip"

  if use 'kernel_linux'; then
    # This is from https://bugs.gentoo.org/376939
    use 'acl' && linux-config-check "TMPFS_POSIX_ACL"
    # This is required to get login-session-id string with pam_ck_connector.so
    use 'pam' && linux-config-check "AUDITSYSCALL"
  fi

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  sed -e '/SystemdService/d' -i data/org.freedesktop.ConsoleKit.service.in || die

  test -x "/bin/perl" && ./autogen.sh

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --libexecdir="${EPREFIX%/}"/lib/ConsoleKit \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    XMLTO_FLAGS='--skip-validation' \
    --localstatedir="${EPREFIX%/}"/var \
    $(use_enable 'pam' pam-module) \
    $(use_enable 'doc' docbook-docs) \
    $(use_enable 'test' docbook-docs) \
    $(use_enable 'debug') \
    $(use_enable 'policykit' polkit) \
    $(use_enable 'evdev' libevdev) \
    $(use_enable 'acl' udev-acl) \
    $(use_enable 'udev' libdrm) \
    $(use_enable 'udev' libudev) \
    $(use_enable 'test' tests) \
    --with-dbus-services="${EPREFIX%/}"/usr/share/dbus-1/services \
    --with-pam-module-dir="/$(get_libdir)/security" \
    --with-xinitrc-dir="${EPREFIX%/}"/etc/X11/xinit/xinitrc.d \
    --without-systemdsystemunitdir \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    $(use_enable 'nls') \
    $(use_enable 'rpath') \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make \
    DESTDIR="${ED}" \
    htmldocdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV}/html \
    ${INSTALL_OPTS} \
    || die "make install... error"

  : dosym ConsoleKit /lib/${PN}

  : dodoc AUTHORS HACKING NEWS README TODO

  : keepdir /usr/lib/ConsoleKit/run-seat.d
  : keepdir /usr/lib/ConsoleKit/run-session.d
  : keepdir /etc/ConsoleKit/run-session.d
  : keepdir /var/log/ConsoleKit

  : exeinto /etc/X11/xinit/xinitrc.d
  : newexe "${FILESDIR}"/90-consolekit-3 90-consolekit

  if use 'kernel_linux'; then
    # bug 571524
    : exeinto /usr/lib/ConsoleKit/run-session.d
    : doexe "${FILESDIR}"/pam-foreground-compat.ck
  fi


  cd "${ED}/" || die "install dir: not found... error"

  rm -vr -- "var/" "usr/share/" || die

  find "$(get_libdir)/" -name '*.la' -delete || die

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'stest' && { ${PROG} --version || : die "binary work... error";}
  ldd ${PROG} || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
