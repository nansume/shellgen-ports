#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-06-22 12:00 UTC - last change
# +static +static-libs -shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32
# Usage [for bootstrap]: USE='+bootstrap +x32' emerge -b -- sys-devel/flex0

export USER XPN PF PV WORKDIR BUILD_DIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
PN=${PN%-*}
XPN=${PN%-*}
XPN=${PN}
PN=${PN%-*}
PN=${PN%[0-9]}
PV="2.5.39"
PV="2.5.33"
XPV=${PV}
DESCRIPTION="The Fast Lexical Analyzer"
HOMEPAGE="https://github.com/westes/flex"
HASH="343374a00b38d9e39d1158b71af37150"
SRC_URI="https://github.com/westes/flex/archive/refs/tags/${PN}-${PV}.tar.gz"
SRC_URI="https://src.fedoraproject.org/lookaside/pkgs/flex/flex-${PV}.tar.bz2/${HASH}/flex-${PV}.tar.bz2"
LICENSE="FLEX"
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
IUSE="+static +static-libs -shared (+musl) (-patch) -debug +stest -test +strip"
IUSE="${IUSE} -nls -rpath -man -doc -bootstrap -xstub"
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
ZCOMP="gunzip"
ZCOMP="bunzip2"
# future:
#WORKDIR="${PDIR%/}/${SRC_DIR}
# future: WORKDIR --> BUILD_DIR
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PN}-${XPV}"
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${XPV}"
BUILD_DIR=${WORKDIR}
S="${PDIR%/}/${SRC_DIR}/${PN}-${PN}-${XPV}"
S="${PDIR%/}/${SRC_DIR}/${PN}-${XPV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
BUILDLIST=${10:-$BUILDLIST}
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

use 'bootstrap' && tc-bootstrap-musl "$(arch)-linux-musl$(usex x32 x32 '')-native.tgz"

pkginst \
  "#dev-lang/perl  # required for autotools" \
  "dev-util/byacc  # alternative a bison" \
  "sys-apps/file" \
  "#sys-devel/autoconf  # required for autotools" \
  "#sys-devel/automake  # required for autotools" \
  "sys-devel/binutils" \
  "#sys-devel/bison" \
  "#sys-devel/flex" \
  "#sys-devel/gettext  # required for autotools" \
  "sys-devel/lex" \
  "#sys-devel/libtool  # required for autotools" \
  "sys-devel/m4" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'bootstrap' || pkginst "sys-devel/gcc"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  printf '#!/bin/sh' > /bin/xutils-stub
  chmod +X /bin/xutils-stub
  ln -sf xutils-stub /bin/makeinfo
  ln -sf xutils-stub /bin/texi2dvi
  ln -sf xutils-stub /bin/help2man
fi

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

  cd "${DISTSOURCE}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

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

  use 'strip' && INSTALL_OPTS='install-strip'

  > doc/flex.pdf

  test -x "/bin/perl" && { autoreconf --install || die;}

	IFS=${NL}

  . runverb \
  ./configure \
    CC="gcc$(usex static ' -static --static')" \
    --prefix="/usr" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${DPREFIX}/share" \
    --infodir="${DPREFIX}/share/info" \
    --mandir="${DPREFIX}/share/man" \
    --host=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
    --build=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    $(use_enable 'nls') \
    $(use_enable 'rpath') \
    LDFLAGS="${LDFLAGS}" \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  . runverb \
  make DESTDIR="${INSTALL_DIR}" ${INSTALL_OPTS} || die "make install... error"

  cd "${INSTALL_DIR}/" || die "install dir: not found... error"

  rm -vr -- "usr/share/"

  # simple test
  LD_LIBRARY_PATH= bin/${PN} --version || die "binary work... error"

  ldd "bin/${PN}" || { use 'static' && true;}

  exit 0
fi

cd "${INSTALL_DIR}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
