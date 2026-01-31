#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Description: Base filesystem for OpenWrt
# Homepage: https://git.openwrt.org/
# License: GPL-2.0
# Depends: <deps>
# Date: 2026-01-29 18:00 UTC - last change
# Build with useflag: -static -static-libs -shared -patch -doc -xstub -diet -musl -stest +noarch

# https://github.com/openwrt/openwrt/archive/master.tar.gz  package/base-files/Makefile

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV=$(date '+%Y%m%d')
SRC_URI=""
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-doc (-musl) -stest -strip"
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
PKGNAME=${PN}
ZCOMP="gunzip"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${HASH}"
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

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

sw-user || die "Failed package build from user... error"  # only for user-build

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build

  CONFIG_TARGET_PREINIT_SUPPRESS_STDERR=
  CONFIG_TARGET_INIT_SUPPRESS_STDERR=
  CONFIG_TARGET_PREINIT_TIMEOUT="4"
  TARGET_INIT_PATH=
  CONFIG_TARGET_INIT_ENV=""
  CONFIG_TARGET_INIT_CMD="/sbin/init"
  CONFIG_TARGET_PREINIT_IFNAME=""
  CONFIG_TARGET_PREINIT_IP="192.168.1.1"
  CONFIG_TARGET_PREINIT_NETMASK="255.255.255.0"
  CONFIG_TARGET_PREINIT_BROADCAST="192.168.1.255"
  CONFIG_TARGET_PREINIT_SHOW_NETMSG=
  CONFIG_TARGET_PREINIT_SUPPRESS_FAILSAFE_NETMSG=
  CONFIG_TARGET_PREINIT_DISABLE_FAILSAFE=

  cd "${ED}/" || die "install dir: not found... error"

  mkdir -p -m 0755 -- etc/config/ etc/crontabs/ etc/rc.d/

  #mkdir -m 0755 -- etc/ etc/apk/ etc/apk/keys/
  #mkdir -p -m 0755 -- CONTROL/ overlay/ www/

  cp -v -r "${PDIR%/}"/files/* -t "${ED}"/

  echo "pi_suppress_stderr=\"${CONFIG_TARGET_PREINIT_SUPPRESS_STDERR}\"" >lib/preinit/00_preinit.conf
  echo "fs_failsafe_wait_timeout=${CONFIG_TARGET_PREINIT_TIMEOUT}" >>lib/preinit/00_preinit.conf
  echo "pi_init_path=\"${TARGET_INIT_PATH}\"" >>lib/preinit/00_preinit.conf
  echo "pi_init_env=${CONFIG_TARGET_INIT_ENV}" >>lib/preinit/00_preinit.conf
  echo "pi_init_cmd=${CONFIG_TARGET_INIT_CMD}" >>lib/preinit/00_preinit.conf
  echo "pi_init_suppress_stderr=\"${CONFIG_TARGET_INIT_SUPPRESS_STDERR}\"" >>lib/preinit/00_preinit.conf
  echo "pi_ifname=${CONFIG_TARGET_PREINIT_IFNAME}" >>lib/preinit/00_preinit.conf
  echo "pi_ip=${CONFIG_TARGET_PREINIT_IP}" >>lib/preinit/00_preinit.conf
  echo "pi_netmask=${CONFIG_TARGET_PREINIT_NETMASK}" >>lib/preinit/00_preinit.conf
  echo "pi_broadcast=${CONFIG_TARGET_PREINIT_BROADCAST}" >>lib/preinit/00_preinit.conf
  echo "pi_preinit_net_messages=\"${CONFIG_TARGET_PREINIT_SHOW_NETMSG}\"" >>lib/preinit/00_preinit.conf
  echo "pi_preinit_no_failsafe_netmsg=\"$CONFIG_TARGET_PREINIT_SUPPRESS_FAILSAFE_NETMSG\"" \
  >>lib/preinit/00_preinit.conf

  echo "pi_preinit_no_failsafe=\"${CONFIG_TARGET_PREINIT_DISABLE_FAILSAFE}\"" >>lib/preinit/00_preinit.conf
  echo ". /lib/functions/uci-defaults.sh" >etc/board.d/99-lan-ip
  echo "logger -t 99-lan-ip \"setting custom default LAN IP\"" >>etc/board.d/99-lan-ip
  echo "board_config_update" >>etc/board.d/99-lan-ip
  echo "json_select network" >>etc/board.d/99-lan-ip
  echo "json_select lan" >>etc/board.d/99-lan-ip
  echo "json_add_string ipaddr ${CONFIG_TARGET_PREINIT_IP}" >>etc/board.d/99-lan-ip
  echo "json_add_string netmask ${CONFIG_TARGET_PREINIT_NETMASK}" >>etc/board.d/99-lan-ip
  echo "json_select .." >>etc/board.d/99-lan-ip
  echo "json_select .." >>etc/board.d/99-lan-ip
  echo "board_config_flush" >>etc/board.d/99-lan-ip

  chmod +x "${ED}"/etc/board.d/* "${ED}"/etc/uci-defaults/* "${ED}"/etc/hotplug.d/*/*
  chmod +x "${ED}"/etc/rc.local "${ED}"/lib/preinit/*
  #chmod +x "${ED}"/etc/shinit

  rm -- lib/upgrade/nand.sh
  rm -- lib/upgrade/emmc.sh
  #rm -- lib/upgrade/legacy-sdcard.sh

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="all" PN=${XPN} PV=${PV} pkg-create-cgz