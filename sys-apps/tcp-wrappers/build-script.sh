#!/bin/sh
# Copyright (C) 2023-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-01-01 22:00 UTC - last change

export USER XPN PF PV WORKDIR S PKGNAME DPREFIX BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:=$PWD}
XPN=${PN}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PKGNAME="tcp_wrappers"
PN="${PN:-${12:?required <PN>}}"
PV="7.6"
DESCRIPTION="TCP Wrappers"
HOMEPAGE="http://ftp.porcupine.org/pub/security"
SRC_URI="
  http://ftp.porcupine.org/pub/security/${PKGNAME}_${PV}.tar.gz
  http://deb.debian.org/debian/pool/main/t/${PN}/${PN}_${PV}.q-32.debian.tar.xz
  https://dev.gentoo.org/~soap/distfiles/${PN}-${PV}.31-patches.tar.xz
  http://data.gpo.zugaina.org/gentoo/sys-apps/${PN}/files/hosts.allow.example
"
LICENSE="tcp_wrappers_license"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="linux"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static-libs +shared +static +diet (+musl) +ipv6 (+patch) +strip"
IUSE="${IUSE} -netgroups -selinux -rfc931 -dot -hostname +fancy"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
DPREFIX="/usr"
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
SDIR="${S}"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
PKGNAME=$(pkgname)
ZCOMP="gunzip"
ZCOMP=$(zcomp-as "${PF}")
WORKDIR="${PDIR%/}/${SRC_DIR}/${PKGNAME}_${XPV}"
WORKDIR="${PDIR%/}/${SRC_DIR}/${PKGNAME}_${PV}"
S="${PDIR%/}/${SRC_DIR}/${PKGNAME}_${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
BUILDLIST=${10:-$BUILDLIST}
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
  #XPV=${PV}-ipv6.4
  #SRC_URI=http://ftp.porcupine.org/pub/security/tcp_wrappers_${XPV}.tar.gz
  #PF=$(pfname src_uri.lst ${SRC_URI})
  #WORKDIR=${PDIR%/}/${SRC_DIR}/${PKGNAME}_${XPV}
  IUSE="${IUSE} +static -ipv6"

  pkginst "dev-libs/dietlibc"
else
  IUSE="${IUSE} -diet"
  pkginst "sys-libs/musl"
  # required for static, otherwise: /bin/ld: cannot find -lwrap
  use 'static' && { pkginst "sys-apps/tcp-wrappers" || die;}
fi

use 'netgroups' && pkginst "net-libs/libnsl"

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

  #use diet ||
  for F in *.tar.xz; do
    unxz -dc ${F} | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf -
    printf %s\\n "unxz -dc ${F} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  for F in $(sed -e 's:^:../debian/patches/:' ../debian/patches/series || die) ../gentoo-patches/*.patch; do
    case ${F} in
      ../debian/patches/13_shlib_weaksym|\
      ../debian/patches/musl_support|\
      ../debian/patches/expand_remote_port|\
      ../debian/patches/fix_warnings|\
      ../debian/patches/rfc931.diff|\
      ../debian/patches/siglongjmp|\
      ../debian/patches/fix_warnings2|\
      ../gentoo-patches/101-C99-decls.patch)
        # with that is build, no have to full patching:
        #  rfc931.diff siglongjmp fix_warnings2 101-C99-decls.patch
        use 'diet' && continue
      ;;
    esac
    test -e "${F}" && { patch -p1 -E < "${F}"; printf %s\\n "patch -p1 -E < ${F}";}
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  if use 'diet'; then
    PATH="${PATH:+${PATH}:}/opt/diet/bin"
  fi
  use 'diet' || append-cppflags "-DHAVE_WEAKSYMS"
  append-cppflags "-DHAVE_STRERROR -DSYS_ERRLIST_DEFINED"
  if use !diet; then
    use 'ipv6' && append-cppflags "-DINET6=1 -Dss_family=__ss_family -Dss_len=__ss_len"
  fi
  use 'rfc931' && append-cppflags "-DRFC931_TIMEOUT=1"
  use 'static' && append-ldflags --static

	IFS=${NL}

  . runverb \
  make -j "1" \
    CC="$(use diet && printf 'diet -Os gcc -nostdinc' || printf gcc)" \
    DESTDIR="${ED}" \
    prefix="${EPREFIX%/}" \
    LIBDIR="${EPREFIX%/}/$(get_libdir)" \
    REAL_DAEMON_DIR="/sbin" \
    TLI= VSYSLOG= PARANOID= BUGS= \
    $(use 'rfc931' && printf "AUTH=-DALWAYS_RFC931" || printf "AUTH=") \
    $(use 'diet' || printf 'AUX_OBJ="weak_symbols.o"') \
    $(usex 'dot' "DOT=-DAPPEND_DOT" "DOT=") \
    $(usex 'hostname' "HOSTNAME=-DALWAYS_HOSTNAME" "HOSTNAME=") \
    NETGROUP=$(usex "netgroups" -DNETGROUPS "") \
    $(usex 'fancy' "STYLE=-DPROCESS_OPTIONS") \
    LIBS=$(usex "netgroups" -lnsl "") \
    LIB=$(usex "static-libs" libwrap.a) \
    COPTS="${CFLAGS} ${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    $(usex 'diet' all musl) \
    || die "Failed make build"

  mkdir -pm 0755 "${ED}/sbin/"
  cp -p safe_finger tcpd tcpdchk tcpdmatch try-from "${ED}/sbin/"
  mkdir -pm 0755 "${ED}/$(get_libdir)/"
  use 'static-libs' && cp -p libwrap.a "${ED}/$(get_libdir)/"
  if use !diet; then
    use 'shared' && cp -p shared/libwrap.so* "${ED}/$(get_libdir)/"
  fi
  mkdir -pm 0755 "${ED}/usr/include/"
  cp -p tcpd.h "${ED}/usr/include/"
  printf %s\\n "Install... ok"

  cd "${ED}/" || die "install dir: not found... error"

  if use 'strip'; then
    strip --verbose --strip-all "sbin/"* "$(get_libdir)/"libwrap.so
    strip --strip-unneeded "$(get_libdir)/"libwrap.a
  fi

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

# simple test
if use 'static'; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH} }:${ED}/$(get_libdir)"
fi
sbin/tcpdchk -h

ldd "sbin/tcpd" || { use 'static' && true;}

pkg-perm

# ipv4 only
if use 'diet'; then
  CATEGORY="app-alternatives"
  PN="tcpd4-static"
fi

INST_ABI="$(tc-abi-build)" pkg-create-cgz
