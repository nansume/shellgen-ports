#!/bin/sh
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-11-22 20:00 UTC - last change

NL="$(printf '\n\t')"; NL=${NL%?} XPWD=${XPWD:=$PWD} XPN=${PN} PKG_DIR='/pkg' LC_ALL='C'

USER=${USER:-root}
USE_BUILD_ROOT='0'
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=${PWD}
LIBDIR=${LIBDIR:-/libx32}
DPREFIX='/usr'
INCDIR="${DPREFIX}/include"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
INSTALL_OPTS='install'
MAKEFLAGS='-j4 V=0'
CFLAGS='-O2 -msse2 -fno-stack-protector -g0'
CPPFLAGS='-O2 -msse2 -fno-stack-protector -g0'
CXXFLAGS='-O2 -msse2 -fno-stack-protector -g0'
FCFLAGS='-O2 -msse2 -fno-stack-protector -g0'
FFLAGS='-O2 -msse2 -fno-stack-protector -g0'
HOSTNAME=$(hostname)
#CPU_NUM=$(cpucore-num)
BUILD_USER='tools'
SRC_DIR='build'
IONICE_COMM='nice -n 19'
XLDFLAGS=

export USER BUILDLIST XPN PF PV LIBDIR WORKDIR PKGNAME DPREFIX PKG_CONFIG_LIBDIR PKG_CONFIG_PATH
export LC_ALL BUILD_USER SRC_DIR CFLAGS CPPFLAGS CXXFLAGS FCFLAGS FFLAGS

if test "X${USER}" != 'Xroot'; then
  ABI_BUILD=${1:?} LIBDIR=${2:?} LIB_DIR=${3:?} PDIR=${4:?} XPWD=${5:?} XPN=${6:?}
  BUILD_CHROOT=${7:?} _ENV=${8} USE_BUILD_ROOT=${9} BUILDLIST=${10} CATEGORY=${11:?} PN=${12:?}
  PWD=${PWD%/}
  mksrc-prepare
elif test "${BUILD_CHROOT:=0}" -eq '0'; then
  PATH="${PATH:+${PATH}:}${PDIR}/misc.d:${PDIR}/etools.d"
elif test "${BUILD_CHROOT:=0}" -ne '0'; then
  PATH="$(xpath):${PDIR%/}/misc.d:${PDIR%/}/etools.d"
  printf %s\\n "PATH='${PATH}'" "PDIR='${PDIR}'"
fi

#BUILDLIST=$(buildlist)

. "${PDIR%/}/etools.d/"pre-env || exit

test "x${SN}" != "x${SN%%_*}" && SN="${SN%%_*}-${SN#*_}"

PF=$(pfname 'src_uri.lst')
PV=$(pkgver)
PKGNAME=$(pkgname)
ZCOMP=$(zcomp-as "${PF}")

printf %s\\n "BUILDLIST='${BUILDLIST}'" "PV='${PV}'" "PKGNAME='${PKGNAME}'"

. "${PDIR%/}/etools.d/"build-functions

chroot-build || exit

#. ${PDIR%/}/etools.d/"pkg-tools-env
. "${PDIR%/}/etools.d/"sh-profile-tools
. "${PDIR%/}/etools.d/"pre-env-chroot

WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-src"

instdeps-spkg-dep || exit
build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

no-ldconfig
netuser-fetch || exit
sw-user || exit

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  :
elif test "X${USER}" != 'Xroot'; then
  #17-prefix_cmake.sh
  #17-python.sh
  : drop-python

  . "${PDIR%/}/etools.d/"gen-variables

  cd "${DISTSOURCE}/" || exit

  test -d "${WORKDIR}" && rm -rf -- "${WORKDIR}/"
  emptydir "${INSTALL_DIR}" || rm -r -- "${INSTALL_DIR}/"*

  #${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  #printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  pkg-unpack "PKGNAME=${PKGNAME}"

  cd "${WORKDIR}/" || exit

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  use 'strip' && INSTALL_OPTS='install-strip'
  #use 'static' && export CC='gcc -static --static'

  src-patch "${DISTSOURCE}/${PN}-${PV%.${PV#*.*.}}-20210620.diff"

  #CPPFLAGS="${CPPFLAGS:+${CPPFLAGS} }-m${ABI}"
  #CXXFLAGS="${CXXFLAGS:+${CXXFLAGS} }-m${ABI}"
  #FCFLAGS="${FCFLAGS:+${FCFLAGS} }-m${ABI}"
  #FFLAGS="${FFLAGS:+${FFLAGS} }-m${ABI}"

  unset CFLAGS CXXFLAGS CPPFLAGS FCFLAGS FFLAGS LDFLAGS

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

  printf %s\\n "MAKEFLAGS='${MAKEFLAGS}'"
  printf %s\\n "CC='${CC}'" "CXX='${CXX}'" "CPP='${CPP}'" "LIBTOOL='${LIBTOOL}'"
  printf %s\\n "CFLAGS='${CFLAGS}'" "CPPFLAGS='${CPPFLAGS}'" "CXXFLAGS='${CXXFLAGS}'"
  printf %s\\n "FCFLAGS='${FCFLAGS}'" "FFLAGS='${FFLAGS}'" "LDFLAGS='${LDFLAGS}'"

  autoreconf

  . runverb \
  ./configure \
    --prefix="${SPREFIX%/}" \
    --bindir="${SPREFIX%/}/bin" \
    --sbindir="${SPREFIX%/}/sbin" \
    --libdir="${SPREFIX%/}/${LIB_DIR}" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-all-programs \
    --disable-agetty \
    --disable-asciidoc \
    --disable-bash-completion \
    --disable-bfs \
    --without-btrfs \
    --disable-chfn-chsh \
    --disable-cramfs \
    --disable-eject \
    --disable-fallocate \
    --disable-fsck \
    --disable-fstrim \
    --disable-gtk-doc \
    --disable-hwclock \
    --disable-makeinstall-chown \
    --disable-makeinstall-setuid \
    --disable-mesg \
    --disable-minix \
    --disable-mountpoint \
    --without-ncurses \
    --without-ncursesw \
    --disable-nologin \
    --disable-partx \
    --disable-pivot_root \
    --disable-plymouth_support \
    --disable-pylibmount \
    --without-python \
    --disable-raw \
    --disable-rfkill \
    --disable-setpriv \
    --disable-swapon \
    --without-systemd \
    --disable-tls \
    --disable-use-tty-group \
    --disable-unshare \
    --disable-utmpdump \
    --disable-widechar \
    --disable-whereis \
    --disable-wipefs \
    --disable-zramctl \
    --without-udev \
    --disable-blkid \
    --enable-losetup \
    --enable-libuuid \
    --enable-libblkid \
    --enable-libmount \
    --disable-switch_root \
    --enable-libsmartcols \
    --enable-static-programs="losetup" \
    $(use_enable 'rpath') \
    $(use_enable 'nls') \
    $(use_enable 'shared') \
    --enable-static || exit

  make -j "$(nproc --ignore=1)" || { exit; die "Failed make build";}

  . runverb \
  make DESTDIR="${INSTALL_DIR}" ${INSTALL_OPTS} || exit

  #######################################################
  export CC="gcc -static --static"
  export CXX="g++ -static --static"
  export LDFLAGS='-s -static --static'

  ./configure --disable-all-programs --enable-switch_root
  make switch_root || exit

  . runverb \
  make DESTDIR="${INSTALL_DIR}" ${INSTALL_OPTS} || exit
  #######################################################

  cd "${INSTALL_DIR}/" || exit

  if test -x 'sbin/losetup'; then
    rm -- sbin/losetup
    mv -vn bin/losetup.static sbin/loop-aes-losetup
    ln -sf loop-aes-losetup sbin/losetup
  fi

  post-inst-perm

  RMLIST="$(pkg-rmlist)" pkg-rm

  post-rm
  pkg-rm-empty
  use 'upx' && upx --best "bin/${PN}"

  use 'stest' && { sbin/loop-aes-losetup --version || : die "binary work... error";}
  ldd "sbin/loop-aes-losetup" || : die "library deps work... error"

  pre-perm
  exit 0
fi

cd "${INSTALL_DIR}/" || exit

pkg-perm

INST_ABI="$(test-native-abi)" pkg-create-cgz
