#!/bin/sh

BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
DESTDIR=${ED}

export PV

local MAKEFLAGS=; unset MAKEFLAGS

test "X${USER:?}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

sed -i 's@^\([[:space:]]\)chown\([[:space:]]\)@\1true\2@' -i Makefile

dodir /etc /usr/share/fonts/jfbterm

make DESTDIR=${ED} install || die "make install... error"

: mv -n "${ED}"/etc/jfbterm.conf.sample "${ED}"/etc/jfbterm.conf

doman jfbterm.1 jfbterm.conf.5

# install example config files
: docinto examples  # BUG: not found
: dodoc jfbterm.conf.sample*
: docompress -x /usr/share/doc/${PN}-${PV}/examples  # BUG: not found