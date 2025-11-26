#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2023-12-15 14:00 UTC, 2025-06-24 18:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sys-apps/busybox/busybox-1.36.1-r3.ebuild

# TODO: Add build it here: httpd_indexcgi, httpd_ssi, ssl_helper by matrixssl, alt login
# TODO: Add build it here: zstdapplets

# [PATCH] Add support for zstd decompression
# https://lists.busybox.net/pipermail/busybox/2021-September/089235.html
# https://github.com/nolange/busybox/commits/zstdapplets

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="Utilities for rescue and embedded systems"
HOMEPAGE="https://www.busybox.net/"
LICENSE="GPL-2-only"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PV="1.36.1"  # stable
PV="1.37.0"  # unstable
BASE_URI="gitlab.alpinelinux.org/alpine/aports/-/blob/master/main/busybox"
SRC_URI="
  https://www.busybox.net/downloads/${PN}-${PV}.tar.bz2
  http://data.gpo.zugaina.org/gentoo/sys-apps/busybox/files/${PN}-1.26.2-bb.patch
  http://data.gpo.zugaina.org/gentoo/sys-apps/busybox/files/${PN}-1.34.1-skip-selinux-search.patch
  #http://data.gpo.zugaina.org/gentoo/sys-apps/busybox/files/${PN}-1.36.0-fortify-source-3-fixdep.patch
  #http://data.gpo.zugaina.org/gentoo/sys-apps/busybox/files/${PN}-1.36.1-kernel-6.8.patch
  #http://data.gpo.zugaina.org/gentoo/sys-apps/busybox/files/${PN}-1.36.1-skip-dynamic-relocations.patch
  https://${BASE_URI}/0001-wget-add-header-Accept.patch
  https://${BASE_URI}/0003-ash-add-built-in-BB_ASH_VERSION-variable.patch
  #https://${BASE_URI}/0008-pgrep-add-support-for-matching-against-UID-and-RUID.patch
  https://${BASE_URI}/0015-ping-make-ping-work-without-root-privileges.patch
  https://${BASE_URI}/0023-Hackfix-to-disable-HW-acceleration-for-MD5-SHA1-on-x.patch
  https://${BASE_URI}/0034-adduser-remove-preconfigured-GECOS-full-name-field.patch
  http://localhost/${PN}_moused_applet_add.patch
  http://data.gpo.zugaina.org/gentoo/sys-apps/busybox/files/ginit.c
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+ipv6 +syslog +verbose +help +usage +fancy +large -hardlink +nofork +sh +multicall"
IUSE="${IUSE} -fancy -debug -sep-usr +static -shared -doc (+musl) +stest +strip"
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
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
PROG="paste"
IONICE_COMM="nice -n 19"

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
  "sys-devel/binutils9" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
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
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -Os  # TODO: replace to: -Oz (Introduced in gcc-12.1,more aggressively optimize for size)
  append-ldflags -Wl,--gc-sections
  append-cflags -ffunction-sections -fdata-sections
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  cp -v -n "${FILESDIR}"/ginit.c -t init/ || : die

  # for error page cgi support
  for F in "${PDIR%/}/patches/"*".diff"; do
    case ${F} in *'*'*) continue;; esac
    [ -f "${F}" ] && patch -p1 -E < "${F}"
  done

  gpatch -p1 -E < "${FILESDIR}"/${PN}-1.26.2-bb.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-1.34.1-skip-selinux-search.patch
  #patch -p1 -E < "${FILESDIR}"/${PN}-1.36.0-fortify-source-3-fixdep.patch
  #patch -p1 -E < "${FILESDIR}"/${PN}-1.36.1-kernel-6.8.patch

  gpatch -p1 -E < "${FILESDIR}"/0001-wget-add-header-Accept.patch
  gpatch -p1 -E < "${FILESDIR}"/0003-ash-add-built-in-BB_ASH_VERSION-variable.patch
  #gpatch -p1 -E < "${FILESDIR}"/0008-pgrep-add-support-for-matching-against-UID-and-RUID.patch
  gpatch -p1 -E < "${FILESDIR}"/0015-ping-make-ping-work-without-root-privileges.patch
  gpatch -p1 -E < "${FILESDIR}"/0023-Hackfix-to-disable-HW-acceleration-for-MD5-SHA1-on-x.patch
  gpatch -p1 -E < "${FILESDIR}"/0034-adduser-remove-preconfigured-GECOS-full-name-field.patch
  gpatch -p1 -E < "${FILESDIR}"/${PN}_moused_applet_add.patch

  cp -v -u "${PDIR}/dist-src/.config" -t .

  make oldconfig || die "Failed make config"

  make -j "$(nproc)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" install || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'stest' && { bin/${PROG} --help || die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz