#!/bin/sh
# -static -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="xAutoClick is an application to reduce RSI by simulating multiple mouse clicks"
HOMEPAGE="http://xautoclick.sourceforge.net/"
LICENSE="GPL-2"
IUSE="-gtk +fltk"
EPREFIX=${SPREFIX}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

sed -i -e 's#moc-qt4#moc#' Makefile

./configure --prefix="${EPREFIX%/}" || die "configure... error"

printf '%s\n' HAVE_GTK2=$(usex 'gtk2' yes no) >> config.mak
printf '%s\n' HAVE_QT4=$(usex 'qt4' yes no) >> config.mak
printf '%s\n' HAVE_FLTK=$(usex 'fltk' yes no) >> config.mak

sed -i -e "s:\$(PREFIX):${ED}:" Makefile

printf "Configure directory: ${PWD}/... ok\n"
