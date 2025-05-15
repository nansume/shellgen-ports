#!/bin/sh
# -static -static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="The Common Unix Printing System"
HOMEPAGE="https://www.cups.org/"
LICENSE="GPL-2"
IUSE="-acl -dbus -debug -java -kerberos +lprng-compat -pam -python -selinux"
IUSE="${IUSE} -ssl -static-libs -systemd +threads -usb -X -xinetd -zeroconf"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
MAKEFLAGS="V=0 prefix= libdir=/$(get_libdir) includedir=/usr/include"

test "X${USER:?}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

make ${MAKEFLAGS} BUILDROOT=${ED} install || die "make install... error"

cd "${ED}/" || return

mv -n lib/${PN} -t $(get_libdir)/ &&
rm -r -- etc/rc.d/
