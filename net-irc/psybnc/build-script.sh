#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-27 14:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-irc/psybnc/psybnc-2.4.3.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="A multi-user and multi-server gateway to IRC networks"
HOMEPAGE="http://www.psybnc.at/index.html"
LICENSE="GPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="2.4.3"
SRC_URI="
  http://psybnc.org/download/psyBNC-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/net-irc/psybnc/files/psybnc.conf
  http://data.gpo.zugaina.org/gentoo/net-irc/psybnc/files/oidentd.conf.psybnc
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+ipv6 -ssl -oidentd -scripting -multinetwork +static -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}"
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
  "#net-dns/c-ares  # it bundled" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
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

  inherit toolchain-funcs install-functions

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-flags -Os
  append-ldflags -Wl,--gc-sections
  append-cflags -ffunction-sections -fdata-sections
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # Useless files
  rm -f */INFO || die

  make -j "$(nproc)" CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" c-ares || die "Failed make build"
  make -j1 CC="${CC}" CFLAGS="-static --static ${CFLAGS}" LDFLAGS="${LDFLAGS}" || die "Failed make build"

  PSYBNC_HOME="/var/lib/psybnc"

  mkdir -m 0755 -- "${ED}/bin/"
  mv -n ${PN} -t "${ED}/bin/" || die "make install... error"
  printf %s\\n "Install: ${PN}... ok"

  insinto /usr/share/psybnc
  doins -r help lang salt.h
  chmod 0600 "${ED}"/usr/share/psybnc/salt.h

  insinto /etc/psybnc
  doins "${FILESDIR}"/psybnc.conf

  : keepdir "${PSYBNC_HOME}"/log
  : keepdir "${PSYBNC_HOME}"/motd
  : keepdir "${PSYBNC_HOME}"/scripts
  : ln -s ../../../usr/share/psybnc/lang "${ED}""${PSYBNC_HOME}"/lang
  : ln -s ../../../usr/share/psybnc/help "${ED}""${PSYBNC_HOME}"/help

  : chown psybnc:psybnc "${ED}"${PSYBNC_HOME}/ "${ED}"${PSYBNC_HOME}/log
  : chown psybnc:psybnc "${ED}"${PSYBNC_HOME}/motd
  : chown psybnc:psybnc "${ED}"/etc/psybnc/psybnc.conf
  : chown psybnc:psybnc "${ED}"${PSYBNC_HOME}/scripts
  : chmod 0750 "${ED}"${PSYBNC_HOME}/ "${ED}"${PSYBNC_HOME}/log
  : chmod 0750 "${ED}"${PSYBNC_HOME}/motd
  : chmod 0750 "${ED}"${PSYBNC_HOME}/scripts
  chmod 0640 "${ED}"/etc/psybnc/psybnc.conf

  if use 'ssl'; then
    : keepdir /etc/psybnc/ssl
    : ln -s ../../../etc/psybnc/ssl "${ED}""${PSYBNC_HOME}"/key
  else
    # Drop SSL listener from psybnc.conf
    sed -e "/^# Default SSL listener$/,+4 d" -i "${ED}"/etc/psybnc/psybnc.conf || die
  fi

  if use 'oidentd'; then
    insinto /etc
    doins "${FILESDIR}"/oidentd.conf.psybnc
    chmod 640 "${ED}"/etc/oidentd.conf.psybnc
    # Install init-script with oidentd-support
    : newinitd "${FILESDIR}"/psybnc-oidentd.initd psybnc
  else
    # Install init-script without oidentd-support
    : newinitd "${FILESDIR}"/psybnc.initd psybnc
  fi

  if use 'scripting'; then
    : dodoc SCRIPTING
  fi

  : newconfd "${FILESDIR}"/psybnc.confd psybnc

  : dodoc CHANGES FAQ README TODO
  : docinto example-script
  : dodoc scripts/example/DEFAULT.SCRIPT

  cd "${ED}/" || die "install dir: not found... error"

  rm -- "usr/share/psybnc/lang/"german.lng "usr/share/psybnc/lang/"italiano.lng

  strip --verbose --strip-all "bin/${PN}"

  LD_LIBRARY_PATH=
  use 'stest' && { bin/${PN} -- || : die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
