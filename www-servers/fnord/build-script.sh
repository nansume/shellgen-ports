#!/bin/sh
# Copyright (C) 2023-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-02-24 01:00 UTC - last change
# Build with useflag: +static +chroot +dirlist +diet +x32

export USER XPN PF PV WORKDIR S PKGNAME DPREFIX BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:=$PWD}
XPN=${PN}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PV="1.11"
DESCRIPTION="Small and fast web server with CGI-capability (inetd)"
HOMEPAGE="http://www.fefe.de/fnord/"
SRC_URI="
  http://www.fefe.de/${PN}/${PN}-${PV}.tar.bz2
  https://cgit.freebsd.org/ports/plain/www/${PN}/files/patch-httpd.c?id=9be02a5db6077e78f20c8b80de14dc177943a3e9
"
# https://cgit.freebsd.org/ports/commit/?id=6bdebd7b07df9117a549dff059265b1cb6ec67b4
SRC_URI="${SRC_URI%[[:cntrl:]]} -> ${PN}-origurl.diff"
LICENSE="GPL-2"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
HOSTNAME="linux"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static -cgi +old-redir -redirect -auth +dirlist (-musl) +diet +strip"
IUSE="${IUSE} -tarpit +chroot +fake-servid -sendfile"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
XPWD=${5:-$XPWD}
P="${P:-${XPWD##*/}}"
SN=${P}
CATEGORY=${11:-$CATEGORY}
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
ZCOMP="bunzip2"
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
S="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
ABI_BUILD="${ABI_BUILD:-${1:?}}"
XPN="${6:-${XPN:?}}"
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
  "sys-devel/gcc" \
  "sys-devel/make" \
  || die "Failed install build pkg depend... error"

if use 'diet'; then
  pkginst "dev-libs/dietlibc"
else
  pkginst "sys-libs/musl"
fi

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  for F in "${FILESDIR}/"*".diff" "${PDIR%/}/patches/"*".diff"; do
    test -e "${F}" && patch -p1 -E < "${F}"
  done

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  use 'fake-servid' && sed -i -e 's|\(\-DFNORD=\).*|\1\\"nginx/1.24.0\\"|g'   Makefile
  use 'cgi'         && sed -i -e "s|^// \(\#define CGI\).*|\1|"               httpd.c
  use 'dirlist'     && sed -i -e "s|^/\* \(\#define DIR_LIST\).*|\1|"         httpd.c
  use 'old-redir'   || sed -i -e "s|^\(\#define OLD_STYLE_REDIRECT\).*|//\1|" httpd.c
  use 'chroot'      || sed -i -e "s|^\(\#define CHROOT\).*|//\1|"             httpd.c
  use 'redirect'    || sed -i -e "s|^\(\#define REDIRECT\).*|//\1|"           httpd.c
  use 'tarpit'      || sed -i -e "s|^\(\#define TARPIT\).*|//\1|"             httpd.c
  use 'sendfile'    || sed -i -e "s|^\(\#define USE_SENDFILE\).*|//\1|"       httpd.c

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')
  append-flags -fomit-frame-pointer

  use 'diet' && PATH="${PATH:+${PATH}:}/opt/diet/bin"

	IFS=${NL}

  . runverb \
  make -j "$(cpun)" \
    CC="$(use diet && printf 'diet -Os gcc -nostdinc' || printf gcc)" \
    CXX="$(use diet && printf 'diet -Os g++ -nostdinc' || printf g++)" \
    CFLAGS="${CFLAGS}" \
    DIET="" \
    ${PN} \
    || die "Failed make build"

  mkdir -pm 0755 "${ED}/bin/"
  mv -n ${PN} "${ED}/bin/"

  #mv -n ${PN}-conf ${ED}/bin/
  #mv -n http ${ED}/bin/${PN}-http
  #mv -n fnord.in ${ED}/bin/

  cd "${ED}/" || die "install dir: not found... error"

  use 'strip' && strip --verbose --strip-all "bin/${PN}"

  use 'static' && LD_LIBRARY_PATH=
  printf '%s\n\n' 'GET / HTTP/1.0' | bin/${PN} .

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

ldd "bin/${PN}" || { use 'static' && true;}

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
