#!/bin/sh
# -static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet -musl -stest -strip +noarch

inherit install-functions

DESCRIPTION="Provides /etc/mime.types file"
HOMEPAGE="https://pagure.io/mailcap"
LICENSE="public-domain MIT"
IUSE="-nginx"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export ED

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

insinto /etc
doins mime.types || exit
if use 'nginx'; then
  insinto /etc/nginx
  doins mime.types.nginx
fi

printf %s\\n "Install: ${PN}... ok"
