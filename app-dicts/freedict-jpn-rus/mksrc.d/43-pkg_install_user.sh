#!/bin/sh
# -static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet -musl -stest -strip +noarch

DESCRIPTION="Dictionary for dictd from Freedict.org"
HOMEPAGE="http://www.freedict.org/"
LICENSE="GPL-2"
DATAFILES="*.dict.dz *.index"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
PV=${PV%.dictd}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 "${ED}"/usr/share/dictd/
mv -n ${DATAFILES} -t "${ED}"/usr/share/dictd/ &&
printf %s\\n "mv -n ${DATAFILES} -t ${ED}/usr/share/dictd/"
