#!/bin/sh

BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 "${ED}"/usr/

mv -n include "${ED}"/usr/ &&
printf %s\\n "mv -n include ${ED}/usr/"
