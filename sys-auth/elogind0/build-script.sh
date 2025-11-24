#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-06-13 20:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sys-auth/elogind/elogind-255.17.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="The systemd project's logind, extracted to a standalone package"
HOMEPAGE="https://github.com/elogind/elogind"
LICENSE="CC0-1.0 LGPL-2.1+ public-domain"
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
PV="252.9"
SRC_URI="
  https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/sys-auth/elogind/files/${PN}-${PV}-nodocs.patch
  http://data.gpo.zugaina.org/gentoo/sys-auth/elogind/files/${PN}-${PV}-musl-lfs.patch
  http://data.gpo.zugaina.org/gentoo/sys-auth/elogind/files/${PN}-${PV}-musl-1.2.5.patch
  http://data.gpo.zugaina.org/gentoo/sys-auth/elogind/files/${PN}-${PV}-py-exec.patch
  http://data.gpo.zugaina.org/gentoo/sys-auth/elogind/files/${PN}-${PV}-musl-sigfillset.patch
  http://data.gpo.zugaina.org/gentoo/sys-auth/elogind/files/${PN}-${PV}-musl-statx.patch
  http://data.gpo.zugaina.org/gentoo/sys-auth/elogind/files/${PN}-${PV}-musl-rlim-max.patch
  http://data.gpo.zugaina.org/gentoo/sys-auth/elogind/files/${PN}-${PV}-musl-getdents.patch
  http://data.gpo.zugaina.org/gentoo/sys-auth/elogind/files/${PN}-${PV}-musl-gshadow.patch
  http://data.gpo.zugaina.org/gentoo/sys-auth/elogind/files/${PN}-${PV}-musl-strerror_r.patch
  http://data.gpo.zugaina.org/gentoo/sys-auth/elogind/files/${PN}-${PV}-musl-more-strerror_r.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-acl -audit -cgroup-hybrid -debug -doc -pam -policykit -selinux -test"
IUSE="${IUSE} -static +static-libs +shared +nopie (+musl) +stest +strip"
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
PROG="loginctl"

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
  "app-shells/bash" \
  "app-text/docbook-xml-dtd42" \
  "app-text/docbook-xml-dtd45" \
  "app-text/docbook-xsl-stylesheets" \
  "dev-build/meson7  # build tool" \
  "#dev-build/muon  # alternative for meson" \
  "dev-build/samurai  # alternative for ninja" \
  "dev-lang/python3-8  # deps meson" \
  "dev-libs/expat  # deps meson,python" \
  "dev-libs/glib74" \
  "dev-libs/gobject-introspection74" \
  "dev-libs/libffi  # deps meson" \
  "dev-libs/libxslt" \
  "dev-libs/pcre2  # deps glib74" \
  "dev-python/py38-jinja2" \
  "dev-python/py38-lxml" \
  "dev-python/py38-markupsafe" \
  "dev-util/gperf" \
  "dev-util/pkgconf" \
  "sys-apps/coreutils" \
  "sys-apps/dbus  # required" \
  "sys-apps/kmod  # deps eudev" \
  "sys-apps/musl-utils  # FIX: getent not found" \
  "sys-apps/util-linux" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/m4  # required for ninja" \
  "sys-devel/make" \
  "sys-fs/eudev" \
  "sys-kernel/linux-headers" \
  "sys-libs/libcap" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps meson" \
  "x11-libs/libx11  # deps dbus" \
  "x11-libs/libxau  # deps dbus" \
  "x11-libs/libxcb  # deps dbus" \
  "x11-libs/libxdmcp  # deps dbus" \
  "x11-libs/libxt  # deps dbus" \
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
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}/${PN}-${PV}-nodocs.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-${PV}-musl-lfs.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-${PV}-musl-1.2.5.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-${PV}-py-exec.patch" # bug 933398

  if use 'musl'; then
    # Some of musl-specific patches break build on the
    # glibc systems (like getdents), therefore those are
    # only used when the build is done for musl.
    patch -p1 -E < "${FILESDIR}/${PN}-${PV}-musl-sigfillset.patch"
    patch -p1 -E < "${FILESDIR}/${PN}-${PV}-musl-statx.patch"
    patch -p1 -E < "${FILESDIR}/${PN}-${PV}-musl-rlim-max.patch"
    patch -p1 -E < "${FILESDIR}/${PN}-${PV}-musl-getdents.patch"
    patch -p1 -E < "${FILESDIR}/${PN}-${PV}-musl-gshadow.patch"
    patch -p1 -E < "${FILESDIR}/${PN}-${PV}-musl-strerror_r.patch"
    patch -p1 -E < "${FILESDIR}/${PN}-${PV}-musl-more-strerror_r.patch"
  fi

  # BUG: include/linux/prctl.h:134:8: error: redefinition of <struct prctl_mm_map>
  # FIX: Include <sys/prctl.h> instead of <linux/prctl.h>
  sed -e "s|#include <linux/prctl.h>$|#include <sys/prctl.h>|" -i src/basic/missing_prctl.h

  meson setup \
    --default-library=$(usex 'shared' both static) \
    -D prefix="/usr" \
    -D bindir="/bin" \
    -D pamconfdir="/etc/pam.d" \
    -D rootlibdir="/$(get_libdir)" \
    -D libdir="/$(get_libdir)" \
    -D pamlibdir="/lib/security" \
    -D udevrulesdir="${EPREFIX%/}"/lib/udev/rules.d \
    -D rootlibexecdir="/$(get_libdir)/elogind" \
    -D libexecdir="/$(get_libdir)/elogind" \
    -D includedir="/usr/include" \
    -D datadir="/usr/share" \
    -D docdir="${EPREFIX%/}/usr/share/doc/${PN}-${PV}" \
    -D htmldir="${EPREFIX%/}/usr/share/doc/${PN}-${PV}/html" \
    -D bashcompletiondir="${EPREFIX%/}/usr/share/bash-completion/completions" \
    -D localstatedir="${EPREFIX%/}"/var \
    -D wrap_mode="nodownload" \
    -D buildtype="release" \
    -D b_colorout="never" \
    -D smack=false \
    -D cgroup-controller=openrc \
    -D default-hierarchy=legacy \
    -D default-kill-user-processes=false \
    -D acl=$(usex 'acl' true false) \
    -D audit=$(usex 'audit' true false) \
    -D html=$(usex 'doc' auto false) \
    -D pam=$(usex 'pam' true false) \
    -D selinux=$(usex 'selinux' true false) \
    -D tests=$(usex 'test' true false) \
    -D utmp=$(usex 'musl' false true) \
    -D dbus=false \
    -D mode=release \
    -D halt-path="${EPREFIX%/}/sbin/halt" \
    -D kexec-path="${EPREFIX%/}/usr/sbin/kexec" \
    -D nologin-path="${EPREFIX%/}/sbin/nologin" \
    -D poweroff-path="${EPREFIX%/}/sbin/poweroff" \
    -D reboot-path="${EPREFIX%/}/sbin/reboot" \
    -D man=false \
    -D b_pie="false" \
    -D tests=$(usex 'test' true false) \
    -D strip=$(usex 'strip' true false) \
    "${BUILD_DIR}/build" "${BUILD_DIR}" \
    || die "meson setup... error"

  ninja -j "$(nproc)" -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${ED}" meson install --no-rebuild -C "${BUILD_DIR}/build" || die "meson install... error"

  cd "${ED}/" || die "install dir: not found... error"

  grep '${prefix}' < $(get_libdir)/pkgconfig/lib${PN}.pc
  sed -e 's|${prefix}||' -i $(get_libdir)/pkgconfig/lib${PN}.pc || die

  rm -vr -- "usr/share/bash-completion/" "usr/share/zsh/"

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir):${ED}/$(get_libdir)/${PN}"
  use 'stest' && { bin/${PROG} --version || die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz