#!/bin/sh
# Copyright (C) 2023-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-02-28 11:00 UTC - last change
# Build with useflag: +static +ipv6 -minimal +diet -musl +x32

export USER XPN PF PV WORKDIR S PKGNAME DPREFIX BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:=$PWD}
XPN=${PN}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PV="0.88"
DESCRIPTION="Collection of tools for managing UNIX services"
HOMEPAGE="http://cr.yp.to/ucspi-tcp.html"
SRC_URI="
  http://cr.yp.to/${PN}/${PN}-${PV}.tar.gz
  http://www.usenix.org.uk/mirrors/qmail/ucspi-rss.diff
  http://smarden.org/pape/djb/manpages/${PN}-${PV}-man.tar.gz
  http://mirrors.mit.edu/gentoo-distfiles/distfiles/93/${PN}-${PV}-rblspp.patch
  http://www.fefe.de/ucspi/${PN}-${PV}-ipv6.diff20.bz2
  http://data.gpo.zugaina.org/gentoo/sys-apps/${PN}/files/${PV}-protos.patch
  http://data.gpo.zugaina.org/gentoo/sys-apps/${PN}/files/${PV}-protos-ipv6.patch
  http://data.gpo.zugaina.org/gentoo/sys-apps/${PN}/files/${PV}-tcprules.patch
  http://data.gpo.zugaina.org/gentoo/sys-apps/${PN}/files/${PV}-bigendian.patch
  http://data.gpo.zugaina.org/gentoo/sys-apps/${PN}/files/${PV}-implicit-int-ipv6.patch
  http://data.gpo.zugaina.org/gentoo/sys-apps/${PN}/files/${PV}-protos-no-ipv6.patch
  http://data.gpo.zugaina.org/gentoo/sys-apps/${PN}/files/${PV}-rblsmtpd-ignore-on-RELAYCLIENT.patch
  http://data.gpo.zugaina.org/gentoo/sys-apps/${PN}/files/${PV}-protos-rblspp.patch
  http://data.gpo.zugaina.org/gentoo/sys-apps/${PN}/files/${PV}-large-responses.patch
  http://data.gpo.zugaina.org/gentoo/sys-apps/${PN}/files/${PV}-uint-headers.patch
  http://data.gpo.zugaina.org/gentoo/sys-apps/${PN}/files/${PV}-implicit-int.patch
  http://data.gpo.zugaina.org/gentoo/sys-apps/${PN}/files/tcprules-Makefile
"
LICENSE="public-domain"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="linux"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static +diet (-musl) -minimal +ipv6 (+patch) -qmail-spp -selinux +strip"
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
ZCOMP="gunzip"
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
S="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
XPN="${6:-${XPN:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
PATCH="patch"

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
  "sys-devel/patch" \
  || die "Failed install build pkg depend... error"

if use 'diet'; then
  IUSE="${IUSE} +static"
  pkginst "dev-libs/dietlibc"
else
  IUSE="${IUSE} -diet"
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
  bunzip2 -d ${PN}-${PV}-ipv6.diff20.bz2

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"
  test -L "/bin/g${PATCH}" || PATCH="/bin/${PATCH}"
  printf %s\\n "PATCH='${PATCH}'"

  ${PATCH} -p1 -E < "${FILESDIR}/${PV}-protos.patch"
  if use 'ipv6'; then
    ${PATCH} -p1 -E < "${FILESDIR}/${PN}-${PV}-ipv6.diff20"
    patch -p1 -E < "${FILESDIR}/${PV}-protos-ipv6.patch"
    patch -p1 -E < "${FILESDIR}/${PV}-tcprules.patch"  #135571
    patch -p1 -E < "${FILESDIR}/${PV}-bigendian.patch" #18892
    patch -p1 -E < "${FILESDIR}/${PV}-implicit-int-ipv6.patch"
  else
    patch -p1 -E < "${FILESDIR}/${PV}-protos-no-ipv6.patch"
  fi
  patch -p1 -E < "${FILESDIR}/ucspi-rss.diff"
  patch -p1 -E < "${FILESDIR}/${PV}-rblsmtpd-ignore-on-RELAYCLIENT.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-${PV}-rblspp.patch"
  patch -p1 -E < "${FILESDIR}/${PV}-protos-rblspp.patch"
  patch -p1 -E < "${FILESDIR}/${PV}-large-responses.patch"
  patch -p1 -E < "${FILESDIR}/${PV}-uint-headers.patch"
  patch -p1 -E < "${FILESDIR}/${PV}-implicit-int.patch"

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

  if use 'diet'; then
    PATH="${PATH:+${PATH}:}/opt/diet/bin"
    printf "diet -Os gcc -nostdinc ${CFLAGS}" > conf-cc || die
    printf "diet -Os gcc -nostdinc ${LDFLAGS}" > conf-ld || die
  else
    printf %s\\n "gcc$(use static && printf ' -static --static') ${CFLAGS}" > conf-cc || die
    printf %s\\n "gcc$(use static && printf ' -s -static --static') ${LDFLAGS}" > conf-ld || die
  fi
  printf %s\\n "${EPREFIX%/}/usr/" > conf-home || die

	IFS=${NL}

  . runverb \
  make -j "$(cpun)" || die "Failed make build"

  # install native
  #${WORKDIR}/install

  mkdir -pm 0755 "${ED}/bin/"
  cp -p tcpserver tcprules tcprulescheck argv0 recordio tcpclient *\@ "${ED}/bin/"
  cp -p tcpcat mconnect mconnect-io addcr delcr fixcrio rblsmtpd "${ED}/bin/"
  if use 'qmail-spp'; then
    mkdir -pm 0755 "${ED}/usr/plugins/"
    cp -p rblspp "${ED}/usr/plugins/"
  fi
  mkdir -pm 0755 "${ED}/etc/tcprules.d/"
  cp -n "${FILESDIR}/tcprules-Makefile" "${ED}/etc/tcprules.d/Makefile"
  printf %s\\n "Install... ok"

  cd "${ED}/" || die "install dir: not found... error"

  use 'strip' && {
  /bin/strip --verbose --strip-all bin/tcpserver bin/tcprules bin/tcprulescheck bin/argv0 bin/recordio
  /bin/strip --verbose --strip-all bin/tcpclient bin/mconnect-io bin/addcr bin/delcr bin/fixcrio bin/rblsmtpd
  }
  # simple test
  use 'static' && LD_LIBRARY_PATH=
  bin/tcpserver --usage

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

ldd "bin/tcpserver" || { use 'static' && true;}

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
