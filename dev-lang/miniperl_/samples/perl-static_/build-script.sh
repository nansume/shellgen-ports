#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-07 16:00 UTC - last change
# Build with useflag: +static-libs +shared -ipv6 -ssl -doc -xstub +musl +stest +strip +x32

export USER XPN PF PV WORKDIR BUILD_DIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH PYTHON

DESCRIPTION="staticperl - perl, libc, 100 modules, all in one standalone 500kb file"
HOMEPAGE="https://metacpan.org/dist/App-Staticperl/view/staticperl.pod"
LICENSE="|| ( Artistic GPL-1+ )"
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${PN}
PN=${PN%-*}
PN=${PN%[0-9]}
PV="5.34.0"
SRC_URI="
  https://www.cpan.org/src/5.0/perl-5.34.0.tar.xz
  https://cpan.metacpan.org/authors/id/M/ML/MLEHMANN/App-Staticperl-1.46.tar.gz
"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="linux"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static-libs -shared (+musl) +ipv6 (-patch) -debug +stest (-test) +strip"
IUSE="${IUSE} -nls -rpath -lfs -upx -man -doc -ncurses (-syslog) -selinux -xstub"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
P="${P:-${XPWD##*/}}"
SN=${P}
PN="${PN:-${P%%_*}}"
PN=${12:-$PN}
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
WORKDIR=${BUILD_DIR}
S="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
#PKG_CONFIG="pkgconf"
#PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
#PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
PATCH="patch"
NPROC=$(nproc)

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
  "dev-lang/perl" \
  "dev-libs/gmp" \
  "dev-libs/mpc" \
  "dev-libs/mpfr" \
  "dev-perl/app-staticperl" \
  "dev-util/byacc" \
  "#dev-util/pkgconf" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/gettext" \
  "sys-devel/lex" \
  "sys-devel/libtool" \
  "sys-devel/m4" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  #sed -e "/^tools:/ s|::/:/bin/sh$|::/build:/bin/sh|" -i /etc/passwd
  #cp -vn "${PDIR%/}/dist-src/".staticperlrc "${PDIR%/}/${SRC_DIR}/"
  cp -vn "${PDIR%/}/dist-src/".staticperlrc "${PDIR%/}/etc/staticperlrc"
  #/sbin/rc.d/[0-9][0-9]-nft stop
  sw-user || die "Failed package build from user... error"  # only for user-build
  #/sbin/rc.d/[0-9][0-9]-nft start
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

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
  CXX="g++$(usex static ' -static --static')"

  use 'strip' && INSTALL_OPTS="install-strip"

  staticperl install
  #staticperl mkbundle
  staticperl mkperl

  #DESTDIR="${ED}" \
  staticperl mkperl --incglob '*' --static

  mkdir -pm 0755 "${ED}"/bin/
  mv -n .staticperl/perl/bin/perl -t "${ED}"/bin/

  cd "${ED}/" || die "install dir: not found... error"

  #use 'upx' && upx --best "bin/${XPN}"

  # simple test
  #LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)/${PN}"
  use 'stest' && { bin/${PN} -v || : die "binary work... error";}

  ldd "bin/${PN}" || : die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
