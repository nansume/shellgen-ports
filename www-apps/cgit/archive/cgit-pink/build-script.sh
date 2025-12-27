#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-05-11 18:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cgit-pink

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="Updated fork of cgit, a web frontend for git"
HOMEPAGE="https://git.causal.agency/cgit-pink/"
LICENSE="GPL-2+"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PV="1.4.1"
PV2="2.45.2"
PV2="2.46.0"
PV2="2.36.1"
SRC_URI="
  https://git.causal.agency/cgit-pink/snapshot/${PN}-${PV}.tar.gz
  https://www.kernel.org/pub/software/scm/git/git-${PV2}.tar.xz
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static -shared -doc (+musl) +stest +strip"
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
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
PROG="cgit.cgi"

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
  "dev-lang/lua54" \
  "dev-libs/gmp  # deps ssl" \
  "dev-libs/pcre2" \
  "dev-libs/openssl3  # deps curl" \
  "#dev-util/byacc  # alternative a bison (posix)" \
  "#dev-util/pkgconf" \
  "dev-vcs/git" \
  "net-dns/c-ares  # deps curl" \
  "net-misc/curl8-2" \
  "#sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "#sys-devel/lex  # alternative a flex (posix)" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  || die "Failed install build pkg depend... error"

pkginst \
  "app-crypt/gnupg" \
  "dev-libs/libassuan" \
  "dev-libs/libgcrypt" \
  "dev-libs/libgpg-error" \
  "dev-libs/libksba" \
  "dev-libs/npth"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

#if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
#  printf '#!/bin/sh' > /bin/git
#  chmod +x /bin/git
#fi

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"  # only for user-build

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  for PF in *.tar.gz *.tar.xz; do
    case ${PF} in '*'.tar.*) continue;; *.tar.gz) ZCOMP="gunzip";; *.tar.xz) ZCOMP="unxz";; esac
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  #append-flags -Os
  #append-ldflags -Wl,--gc-sections
  #append-ldflags "-s -static --static"
  #append-cflags -ffunction-sections -fdata-sections
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  rmdir -- "git/"
  mv -n "${WORKDIR}"/git-"${PV2}" git || die

  #echo "${PV}" > VERSION

  #sed -e '/^#include <stdbool.h>$/a #include <stddef.h>' -i cgit.c
  #sed -e '/^#include "builtin.h"$/a #include <stddef.h>' -i git/git.c
  sed \
    -e '/^#include "sigchain.h"$/a #include <unistd.h>' \
    -e '/^#include "sigchain.h"$/a #include <linux/types.h>' \
    -e '/^#include "sigchain.h"$/a #include <assert.h>' \
    -e '/^#include "sigchain.h"$/a #include <stddef.h>' \
    -e '/^#include "sigchain.h"$/a #include <string.h>' \
    -e '/^#include "sigchain.h"$/a #include <stdarg.h>' \
    -e '/^#include "sigchain.h"$/a #include <stdio.h>' \
    -i git/compat/terminal.c

  make -j "1" \
    CC="${CC}" \
    CFLAGS="${CFLAGS} -I${BUILD_DIR} -Doff_t=__off_t -Duint64_t=__uint_t" \
    NO_ICONV=YesPlease \
    NO_GETTEXT=YesPlease \
    NO_TCLTK=YesPlease \
    NO_SVN_TESTS=YesPlease \
    NO_REGEX=NeedsStartEnd \
    LUA_PKGCONFIG=$(getELUA) \
    prefix="" \
    || die "Failed make build"

  make DESTDIR="${ED}" prefix="" CGIT_SCRIPT_PATH="/usr/share/webapps/cgit" install || die "make install... error"

  #mkdir -pm 0755 -- "${ED}/bin/"
  #mv -n ${PN} -t "${ED}"/bin/ || die "Install... error"
  #printf %s\\n "Install: ${PN}... ok"

  cd "${ED}/" || die "install dir: not found... error"

  ln -s "cgit.cgi" usr/share/webapps/cgit/cgit

  strip --verbose --strip-all "usr/share/webapps/cgit/"${PROG}

  use 'stest' && { "usr/share/webapps/cgit/"${PROG} --version || : die "binary work... error";}
  ldd "usr/share/webapps/cgit/"${PROG} || { use 'static' && true || : die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz