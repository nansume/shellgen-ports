#!/bin/sh
# +static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="A set of SUID mounting tools for use with v9fs."
HOMEPAGE="http://sqweek.dnsdojo.org/code/9mount/"
LICENSE="ISC"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
PROGS="9bind ${PN} 9umount"

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

#chown root:users -- ${PROGS}
chmod 4755 -- ${PROGS}
mkdir -pm 0755 "${ED}"/bin/
mv -n ${PROGS} "${ED}"/bin/ &&

printf %s\\n "Install: ${PROGS} bin/"
