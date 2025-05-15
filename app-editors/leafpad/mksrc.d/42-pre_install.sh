#!/bin/sh
# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Simple GTK2 text editor"
HOMEPAGE="http://tarot.freeshell.org/leafpad/"
LICENSE="GPL-2"
IUSE="-emacs"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
PROGS="src/${PN}"

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

mkdir -pm 0755 -- "${ED}"/bin/
mv -n ${PROGS} -t "${ED}"/bin/ &&

printf %s\\n "Install: ${PN}"
