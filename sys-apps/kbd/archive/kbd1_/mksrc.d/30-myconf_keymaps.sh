#!/bin/sh
# Build with useflag: +static -static-libs -shared -lfs +nopie -patch -doc -xstub +diet -musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sys-apps/kbd/kbd-2.8.0.ebuild

DESCRIPTION="Keyboard and console utilities"
HOMEPAGE="https://kbd-project.org/"
LICENSE="GPL-2"
IUSE="-nls -selinux -pam -test"

export OPTIONAL_PROGS="openvt"
#export SHELL="/bin/bash" CONFIG_SHELL="/bin/bash"

MYCONF="${MYCONF}
 --enable-optional-progs=${OPTIONAL_PROGS}
 --disable-vlock
 --disable-tests
 --enable-libkfont
"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  #ln -v -s /opt/diet/include/linux/vt.h /opt/diet/include/sys/
  :
elif test "X${USER}" != 'Xroot' && use 'diet'; then
  sed -e 's|^#include <sys/vt.h>$|#include <linux/vt.h>|' -i src/openvt.c
  # FIX: for diet libc
  sed -e "s|RESIZECONS_PROGS=yes|RESIZECONS_PROGS=no|" -i configure
  sed -e "s|KEYCODES_PROGS=yes|KEYCODES_PROGS=no|" -i configure
  #sed -e "s|chmod --reference=|/bin/chmod --reference=|" -i Makefile.common
fi
