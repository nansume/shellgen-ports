#!/bin/sh
# +static -static-libs -shared -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

# http://gpo.zugaina.org/net-analyzer/cryptcat

export ED PV PN

DESCRIPTION="Netcat clone extended with twofish encryption (c++)"
HOMEPAGE="https://cryptcat.sourceforge.io"
LICENSE="GPL-2"
PROGS=${PN}
DOCS="Changelog README README.${PN} netcat.blurb"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

dobin ${PROGS} || exit
dodoc ${DOCS}

printf %s\\n "Install: ${PN}... ok"
