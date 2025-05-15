#!/bin/sh
# +static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet +musl -stest +strip +x32

DESCRIPTION="This plugin allows Dillo to open pages using the Gopher protocol"
HOMEPAGE="https://github.com/dillo-browser/dillo-plugin-gopher"
LICENSE="GPLv3+"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
PROGS="gopher.filter.dpi"

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

mkdir -pm 0755 -- "${ED}"/$(get_libdir)/dillo/dpi/gopher/
mv -n ${PROGS} -t "${ED}"/$(get_libdir)/dillo/dpi/gopher/ &&
printf %s\\n "echo 'proto.gopher=gopher/gopher.filter.dpi' >> /etc/dillo/dpidrc"
printf %s\\n "Install: ${PN}"

rm -- Makefile
