#!/bin/sh
# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="pyasn1 modules"
HOMEPAGE="https://pypi.org/project/pyasn1-modules/"
LICENSE="BSD-2"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
PROGS=${PN}

local PN=${PN#py[2-4][1-9]-}

printf %s\\n "PN='${PN}'" "PV='${PV}'"

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

mkdir -pm 0755 -- "${ED}"/usr/share/${PN}-${PV}/
mv -n tools -t "${ED}"/usr/share/${PN}-${PV}/ &&
printf %s\\n "Install: tools -> usr/share/${PN}-${PV}/"
