#!/bin/sh

BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

mv -v -n "${ED}"/lib/libdevmapper.so -t "${ED}"/$(get_libdir)/
mv -v -n "${ED}"/libexec -t "${ED}"/usr/
rmdir -- "${ED}"/lib/

printf %s\\n "Install fix: ${PN}"
