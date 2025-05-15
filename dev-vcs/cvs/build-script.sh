#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-03-14 18:00 UTC - last change
# Build with useflag: +static -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/cvs-1.12.12-r15.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="Concurrent Versions System - source code revision control tools"
HOMEPAGE="https://cvs.nongnu.org/"
LICENSE="GPL-2 LGPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="1.12.12"
SRC_URI="
  mirror://gnu/non-gnu/cvs/source/feature/${PV}/${PN}-${PV}.tar.bz2
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/${PN}-${PV}-cvsbug-tmpfix.patch
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/cvs-1.12.12-openat.patch
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/cvs-1.12.12-block-requests.patch
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/cvs-1.12.12-cvs-gnulib-vasnprintf.patch
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/${PN}-${PV}-install-sh.patch
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/${PN}-${PV}-hash-nameclash.patch #for-AIX
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/${PN}-${PV}-getdelim.patch #314791
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/${PN}-1.12.12-rcs2log-coreutils.patch #144114
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/${PN}-${PV}-mktime-x32.patch #395641
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/${PN}-${PV}-fix-massive-leak.patch
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/${PN}-${PV}-mktime-configure-m4.patch #220040 #570208
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/${PN}-${PV}-CVE-2012-0804.patch
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/${PN}-${PV}-format-security.patch
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/${PN}-${PV}-musl.patch
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/${PN}-${PV}-CVE-2017-12836-commandinjection.patch
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/0001-gettext-autoreconf.patch
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/0001-fix-quoting-around-potentially-empty-shell-var.patch
  http://data.gpo.zugaina.org/gentoo/dev-vcs/cvs/files/c99-roundup.patch
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
IUSE="-crypt -doc -kerberos -nls -pam -selinux +server"
IUSE="${IUSE} +static -shared (+musl) +stest +strip"
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
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-libs/musl0" \
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
  if use !shared || use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
    append-ldflags "-s -static --static"
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-cvsbug-tmpfix.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-openat.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-block-requests.patch
  gpatch -p1 -E < "${FILESDIR}"/${PN}-${PV}-cvs-gnulib-vasnprintf.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-install-sh.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-hash-nameclash.patch # for AIX
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-getdelim.patch # 314791
  patch -p1 -E < "${FILESDIR}"/${PN}-1.12.12-rcs2log-coreutils.patch # 144114
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-mktime-x32.patch # 395641
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-fix-massive-leak.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-mktime-configure-m4.patch #220040 #570208
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-CVE-2012-0804.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-format-security.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-musl.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-CVE-2017-12836-commandinjection.patch
  patch -p1 -E < "${FILESDIR}"/0001-gettext-autoreconf.patch
  patch -p1 -E < "${FILESDIR}"/0001-fix-quoting-around-potentially-empty-shell-var.patch
  patch -p1 -E < "${FILESDIR}"/c99-roundup.patch

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --infodir="${EPREFIX%/}"/usr/share/info/${PN}-${PV} \
    --without-external-zlib \
    --with-tmpdir="${EPREFIX%/}"/tmp \
    $(use_enable 'crypt' encryption) \
    --without-gssapi \
    $(use_enable 'nls') \
    --disable-pam \
    $(use_enable 'server') \
    --disable-nls \
    --disable-rpath \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -r -- usr/share/info/ usr/share/man/

  ln -sf ../usr/share/cvs/contrib/rcs2log bin/

  use 'stest' && { bin/${PN} --version || die "binary work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz