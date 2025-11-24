#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-10-13 01:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-dns/dnsmasq/dnsmasq-2.91.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Small forwarding DNS server"
HOMEPAGE="https://thekelleys.org.uk/dnsmasq/doc.html"
LICENSE="|| ( GPL-2 GPL-3 )"
IFS="$(printf '\n\t ')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
PV="2.80"
PV="2.90"  # TODO: bump to v2.91
PV="2.91"
SRC_URI="
  https://thekelleys.org.uk/dnsmasq/${PN}-${PV}.tar.xz
  #http://localhost/${PN}-${PV}-p001-regex-server.diff
  #http://localhost/${PN}-2.80p1-regex-server.diff  # v2.80
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
IUSE="-auth-dns -conntrack -dbus +dhcp -dhcp-tools -dnssec -dumpfile -id -idn -libidn2"
IUSE="${IUSE} -loop -inotify +ipv6 -lua -nettlehash -nls +script -selinux +static +tftp -regex"
IUSE="${IUSE} (-static-libs) -shared -doc (+musl) +stest +strip"
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
ZCOMP="unxz"
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
  "dev-util/pkgconf" \
  "sys-devel/binutils" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
  "#sys-devel/patch" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'regex' && pkginst "dev-libs/pcre"

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
  if use !shared && use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc$(usex static ' -static --static')"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  #patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-p001-regex-server.diff
  use 'regex' && patch -p1 -E < "${FILESDIR}"/${PN}-2.80p1-regex-server.diff

  #patches/sort-compat-fix.diff
  for F in "${PDIR%/}/patches/"*".diff"; do
    #case ${F} in *'-net_raw-drop.'*);; *) continue;; esac
    patch -p1 -E < "${F}"
  done

  COPTS="-DNO_DBUS -DNO_UBUS -DNO_IDN -DNO_LIBIDN2 -DNO_IPSET -DNO_CONNTRACK -DNO_LUASCRIPT"
  COPTS="${COPTS} -DNO_DNSSEC -DNO_AUTH$(usex !script ' -DNO_SCRIPT') -DNO_GMP -DNO_LOOP -DNO_DHCP6"
  COPTS="${COPTS} -DNO_INOTIFY -DNO_ID$(usex regex ' -DHAVE_REGEX')$(usex !dhcp ' -DNO_DHCP')"
  COPTS="${COPTS}$(usex !ipv6 ' -DNO_IPV6') -DNO_DUMPFILE$(usex !tftp ' -DNO_TFTP')"

  make -j "$(nproc)" COPTS="${COPTS}" || die "Failed make build"

  make \
    DESTDIR="${ED}" \
    PREFIX="${EPREFIX%/}" \
    BINDIR="${EPREFIX%/}/bin" \
    MANDIR="${DPREFIX}/share/man" \
    LOCALEDIR="${DPREFIX}/share/locale" \
    install || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -vr -- "usr/share/man/" "usr/"

  strip --verbose --strip-all "bin/${PN}"

  use 'stest' && { bin/${PN} --version || die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}  # TIP! check is wrong.

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz