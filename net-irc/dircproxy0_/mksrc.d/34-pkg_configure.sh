#!/bin/sh
# +static +static-libs -shared -upx +patch -doc -man -xstub +diet -musl +stest +strip +x32

DESCRIPTION="dircproxy is an IRC proxy server (bouncer,inetd)."
HOMEPAGE="https://github.com/w8tvi/dircproxy"
HOMEPAGE="http://code.google.com/p/dircproxy/"
LICENSE="GPLv2"
IUSE="-ssl"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

export EPREFIX

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

./configure \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --sbindir="${EPREFIX%/}/sbin" \
  --datadir="${DPREFIX}/share" \
  --host=$(tc-chost) \
  --build=$(tc-chost) \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  $(use_enable 'nls') \
  $(use_enable 'rpath') \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"
