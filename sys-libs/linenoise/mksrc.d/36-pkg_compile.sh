#!/bin/sh
# -static -static-libs +shared -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="A small self-contained alternative to readline and libedit"
HOMEPAGE="https://github.com/antirez/linenoise"
LICENSE="BSD"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

cc -shared -fPIC linenoise.c -o liblinenoise.so

rm -- Makefile

mkdir -pm 0755 "${ED}"/$(get_libdir)/ "${ED}"/usr/include/
mv -n lib${PN}.so "${ED}"/$(get_libdir)/ &&
mv -n ${PN}.h -t "${ED}"/usr/include/ &&

printf %s\\n "Install: ${PN}"
