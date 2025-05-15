#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -man -xstub -diet -musl -stest -strip +noarch

local IFS="$(printf '\n\t') "

DESCRIPTION="Updated config.sub and config.guess file from GNU"
HOMEPAGE="https://savannah.gnu.org/projects/config"
LICENSE="GPL-3+-with-autoconf-exception"
PROGS="config.guess config.sub"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 "${ED}"/usr/share/${PN}/

mv -n ${PROGS} -t "${ED}"/usr/share/${PN}/ &&
#fperms +x /usr/share/${PN}/config.{sub,guess}

printf %s\\n "Install: ${PN}... ok"
