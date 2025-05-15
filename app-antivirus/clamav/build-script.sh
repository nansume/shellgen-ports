#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-17 21:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Clam Anti-Virus Scanner"
HOMEPAGE="https://www.clamav.net/"
LICENSE="GPL-2"  # --disable-unrar otherwise a nofree unRAR license
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
PV="0.103.11"
PROG="sbin/clamd"
SRC_URI="
  https://www.clamav.net/downloads/production/${PN}-0.103.11.tar.gz
  http://data.gpo.zugaina.org/gentoo/app-antivirus/clamav/files/clamav-0.102.1-libxml2_pkgconfig.patch
  http://data.gpo.zugaina.org/gentoo/app-antivirus/clamav/files/clamav-0.102.2-fix-curl-detection.patch
  http://data.gpo.zugaina.org/gentoo/app-antivirus/clamav/files/clamav-0.103.0-system-tomsfastmath.patch
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
IUSE="-bzip2 -doc -clamonacc -clamdtop -clamsubmit +iconv +ipv6 -libclamav-only"
IUSE="${IUSE} -milter -metadata-analysis-api -selinux -systemd -test -xml"
IUSE="${IUSE} (+musl) +stest +strip"
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
  "dev-libs/libxml2" \
  "dev-libs/openssl3" \
  "dev-libs/openssl" \
  "dev-libs/pcre  # for vala,glib(optional)" \
  "#dev-libs/pcre2" \
  "dev-libs/tomsfastmath" \
  "dev-util/pkgconf" \
  "net-misc/curl" \
  "sys-apps/file" \
  "sys-devel/autoconf  # required for autotools" \
  "sys-devel/automake  # required for autotools" \
  "sys-devel/binutils" \
  "sys-devel/bison" \
  "sys-devel/gcc9" \
  "sys-devel/lex" \
  "sys-devel/libtool  # required for autotools" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/fts-standalone" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
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
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  use 'musl' && append-ldflags -lfts

  CC="gcc"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}/${PN}-0.102.1-libxml2_pkgconfig.patch"    #661328
  patch -p1 -E < "${FILESDIR}/${PN}-0.102.2-fix-curl-detection.patch"   #709616
  patch -p1 -E < "${FILESDIR}/${PN}-0.103.0-system-tomsfastmath.patch"  # 649394

  rm -r -- libclamav/tomsfastmath/ || die "failed to remove bundled tomsfastmath"

  test -x "/bin/perl" && AT_NO_RECURSIVE="yes" autoreconf

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'bzip2') \
    --disable-unrar \
    $(use_enable 'clamonacc') \
    $(use_enable 'clamdtop') \
    $(use_enable 'ipv6') \
    $(use_enable 'milter') \
    $(use_enable 'test' check) \
    $(use_with 'xml') \
    $(use_with 'iconv') \
    --without-libjson \
    $(use_enable 'libclamav-only') \
    $(use_with !libclamav-only libcurl) \
    --with-system-libmspack \
    --cache-file="${S}"/config.cache \
    --disable-experimental \
    --disable-static \
    --disable-zlib-vcheck \
    --enable-id-check \
    --with-dbdir="${EPREFIX}"/var/lib/clamav \
    --with-zlib \
    --disable-llvm \
    --disable-openrc \
    --runstatedir=/run \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    $(use_enable 'nls') \
    $(use_enable 'rpath') \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -vr -- "usr/share/"

  find "$(get_libdir)/" -name '*.la' -delete || die

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'stest' && { ${PROG} --version || : die "binary work... error";}
  ldd ${PROG} || { use 'static' && true || : die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
