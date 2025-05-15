#!/bin/sh
# +static -static-libs -shared -upx -patch +doc -xstub -diet +musl +stest +strip +x32

inherit eutils

export PN PV ED EPREFIX

local IFS="$(printf '\n\t') "; local EPREFIX=${SPREFIX}

DESCRIPTION="Trick Or Treat Daemon, a DNS proxy for 6to4"
HOMEPAGE="http://www.dillema.net/software/totd.html"
LICENSE="totd BSD BSD-4"
PROGS=${PN}
MANFILES="${PN}.8"
DOCS="${PN}.conf.sample README INSTALL"
EPREFIX=${SPREFIX%/}
BUILD_DIR=${WORKDIR}

unset MAKEFLAGS

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

. runverb \
./configure \
  --prefix="${EPREFIX}"/usr \
  --sysconfdir="${EPREFIX}"/etc \
  --datadir="${EPREFIX}"/usr/share \
  --host=$(tc-chost) \
  --build=$(tc-chost) \
  --enable-ipv4 \
  --enable-ipv6 \
  --enable-stf \
  --enable-scoped-rewrite \
  --disable-http-server \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  $(use_enable 'nls') \
  $(use_enable 'rpath') \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"

make -j"$(nproc)" V='0' all || die "Failed make build"

dosbin ${PROGS}
doman ${MANFILES}
dodoc ${DOCS}

rm -- Makefile*
