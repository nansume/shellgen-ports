#!/bin/sh
# +static -static-libs -shared +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# sample/ports-bug/app-misc/f3/f3-9999.ebuild
# https://data.gpo.zugaina.org/bgo-overlay/app-misc/f3/f3-5.0.ebuild

DESCRIPTION="F3 - Fight Flash Fraud / an alternative to h2testw"
DESCRIPTION="Fight Flash Fraud, or Fight Fake Flash"
HOMEPAGE="http://oss.digirati.com.br/f3/"
EGIT_REPO_URI="https://github.com/AltraMayor/f3"
LICENSE="GPL-3"
IUSE="+static -shared +nopie -doc (+musl) +stest +strip"
BUILD_DIR=${WORKDIR}
ED=${ED:-$INSTALL_DIR}

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

# FIX: for static build
use 'static' &&
sed \
  -e "s/\$(LDFLAGS)/${LDFLAGS} -largp/" \
  -e 's/-lparted$/-ludev -lparted -luuid -lblkid/' \
  -i Makefile

make -j "$(nproc)" all extra || die "Failed make build"

make DESTDIR=${ED} install install-extra || die "make install... error"

rm -- Makefile