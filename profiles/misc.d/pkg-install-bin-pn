#!/bin/sh

BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
PROGS=${PN}

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

mkdir -pm 0755 -- "${ED}"/bin/
mv -n ${PROGS} -t "${ED}"/bin/ &&
printf %s\\n "Install: ${PROGS} bin/"
