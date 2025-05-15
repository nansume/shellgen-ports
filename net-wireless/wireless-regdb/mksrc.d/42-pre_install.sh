#!/bin/sh
# -static -static-libs -shared -nopie -patch -doc -xstub -diet -musl -stest -strip +noarch

DESCRIPTION="Wireless Regulatory database for Linux"
HOMEPAGE="https://wireless.wiki.kernel.org/en/developers/regulatory/wireless-regdb"
LICENSE="ISC"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
DATAFILES="regulatory.db"

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

mkdir -pm 0755 -- "${ED}"/etc/wireless-regdb/pubkeys/
mkdir -pm 0755 -- "${ED}"/lib/firmware/ "${ED}"/lib/crda/

mv -n *.key.pub.pem "${ED}"/etc/wireless-regdb/pubkeys/     # for crda

mv -n ${DATAFILES} "${ED}"/lib/firmware/regulatory.db.p7s
mv -n regulatory.bin -t "${ED}"/lib/crda/                   # for crda

printf %s\\n "Install: ${DATAFILES} /lib/firmware/"
