#!/bin/sh
# +static +static-libs -shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

export PN PV ED EPREFIX CC CXX CBUILD CHOST

local IFS="$(printf '\n\t') "; local EPREFIX=${SPREFIX}

DESCRIPTION="Displays various tables of DNS traffic on your network"
HOMEPAGE="https://github.com/measurement-factory/dnstop"
LICENSE="BSD"
EPREFIX=${SPREFIX%/}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
PROGS="${PN}"
CBUILD=$(tc-chost)
CHOST=$(tc-chost)

unset MAKEFLAGS

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

eautoreconf

append-cflags -D_GNU_SOURCE

econf --enable-ipv6 || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"

#emake
make -j"$(nproc)" V='0' DESTDIR=${ED} all || die "Failed make build"

rm -- Makefile

dobin ${PROGS}
doman ${PN}.8
dodoc 'CHANGES'
