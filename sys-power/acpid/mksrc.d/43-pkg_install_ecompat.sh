#!/bin/sh
# +static -static-libs -shared +lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit install-functions

DESCRIPTION="Daemon for Advanced Configuration and Power Interface"
HOMEPAGE="https://sourceforge.net/projects/acpid2/"
LICENSE="GPL-2"
IUSE="-selinux"
PF="${PN}-${PV}"
FILESDIR=${FILESDIR:-$DISTSOURCE}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
D=${ED}

export PN PV ED D BUILD_DIR

local IFS="$(printf '\n\t') "

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

rm -- "${FILESDIR}"/acpid-1.0.*-default*.sha256
cp -L -f "${FILESDIR}"/acpid-1.0.*-default* -t "${FILESDIR}"/

newdoc kacpimon/README README.kacpimon
dodoc -r samples
rm -f "${D}"/usr/share/doc/${PF}/COPYING || die

exeinto /etc/acpi
newexe "${FILESDIR}"/${PN}-1.0.6-default.sh default.sh
exeinto /etc/acpi/actions
newexe samples/powerbtn/powerbtn.sh powerbtn.sh
insinto /etc/acpi/events
newins "${FILESDIR}"/${PN}-1.0.4-default default

printf %s\\n "Install: ${PN}... ok"
