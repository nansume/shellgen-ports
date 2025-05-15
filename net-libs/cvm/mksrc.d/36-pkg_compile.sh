#!/bin/sh
# diet: +static +static-libs -shared -upx +patch -doc -xstub +diet -musl +stest +strip +x32
# musl: -static +static-libs +shared -upx +patch -doc -xstub -diet +musl +stest +strip +x32

inherit toolchain-funcs install-functions

DESCRIPTION="Credential Validation Modules by Bruce Guenter"
HOMEPAGE="http://untroubled.org/cvm/"
LICENSE="GPL-2+"
IUSE="-mysql -postgres -test -vpopmail -vmailmgr"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
PROGS="cvm-checkpassword cvm-chain cvm-v1testclient cvm-pwfile cvm-unix cvm-testclient"
PROGS="${PROGS} cvm-qmail cvm-v1checkpassword cvm-v1benchclient cvm-benchclient"

export PN PV EPREFIX ED

local EPREFIX=${SPREFIX%/}

unset MAKEFLAGS

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

use 'vmailmgr' && PROGS="${PROGS} cvm-vmailmgr cvm-vmailmgr-local cvm-vmailmgr-udp"

# disable this test, as it breaks under Portage
# and there is no easy fix
sed -i.orig \
 -e '/qmail-lookup-nodomain/,/^END_OF_TEST_RESULTS/d' \
 tests.sh || die "sed failed"
# Fix the vpopmail build
sed -i.orig \
 -e '/.\/ltload cvm-vchkpw/s,-lmysqlclient,,g' \
 -e '/.\/ltload cvm-vchkpw/s,-L/usr/local/vpopmail/lib,,g' \
 -e '/.\/ltload cvm-vchkpw/s,-L/var/vpopmail/lib,,g' \
 -e '/.\/ltload cvm-vchkpw/s,-L/usr/local/lib/mysql,,g' \
 -e '/.\/ltload cvm-vchkpw/s,\.la,.la `cat /var/vpopmail/etc/lib_deps`,g' \
 Makefile \
 || die "Failed to fix vpopmail linking parts of Makefile"
sed -i.orig \
 -e '/.\/compile cvm-vchkpw/s,$, `cat /var/vpopmail/etc/inc_deps`,g' \
 Makefile \
 || die "Failed to fix vpopmail compiling parts of Makefile"
sed -i '/\-rpath/s|conf\-lib|conf\-rpath|' Makefile || die

printf '%s\n' "${ED}/usr/include" > conf-include || die
printf '%s\n' "${ED}/$(get_libdir)" > conf-lib || die
printf '%s\n' "${ED}/bin" > conf-bin || die
printf '%s\n' "${EPREFIX}/$(get_libdir)" > conf-rpath || die
printf '%s\n' "${CC} ${CFLAGS}" > conf-cc || die
printf '%s\n' "${CC} ${LDFLAGS} -g0 -L${EPREFIX}/$(get_libdir)/bglibs -lcrypt" > conf-ld || die

emake -j1 libraries ${PROGS}

# Upstreams installer is incredibly broken
dolib.a .libs/*.a
use 'diet' || dolib.so .libs/*.so*

for i in a $(usex 'shared' so); do
  dosym libcvm-v2client.${i} /$(get_libdir)/libcvm-client.${i}
done

dobin ${PROGS}
use 'mysql' && dobin cvm-mysql cvm-mysql-local cvm-mysql-udp
use 'postgres' && dobin cvm-pgsql cvm-pgsql-local cvm-pgsql-udp
use 'vpopmail' && dobin cvm-vchkpw

insinto /usr/include/cvm
doins credentials.h errors.h facts.h module.h protocol.h sasl.h v1client.h v2client.h
dosym v1client.h /usr/include/cvm/client.h
dosym cvm/sasl.h /usr/include/cvm-sasl.h

dodoc ANNOUNCEMENT NEWS NEWS.sql NEWS.vmailmgr
dodoc README README.vchkpw README.vmailmgr
dodoc TODO VERSION ChangeLog*
docinto html
dodoc *.html

rm -- Makefile*
