#!/bin/sh
# 2021-2023

local IFS="$(printf '\n\t')"; IFS=" ${IFS%?}"
local PKGNAME=${PKGNAME}; local RMLIST

test "X${USER}" != 'Xroot' || return 0

export PKGNAME

cd "${DISTSOURCE}/" || exit

. gen-variables
pkg-unpack PKGNAME=${PKGNAME} && USE_BUILD_ROOT='0'

cd "${WORKDIR}/" || exit

printf %s\\n "Configure directory: PWD='${PWD}'... ok"

printf %s\\n "-Dprivlib='/${LIB_DIR}/${PN}${PV%${PV#?}}'"
printf %s\\n "-Dsitelib='/${LIB_DIR}/${PN}${PV%${PV#?}}/site_${PN}/${PV}'"

yes 'y' | sh 'Configure' \
 -des \
 -Dcc='gcc' \
 -Dccflags='-fno-stack-protector' \
 -Ud_off64_t \
 -Dprefix=' ' \
 -Dprivlib="/${LIB_DIR}/${PN}${PV%${PV#?}}" \
 -Dsitelib="/${LIB_DIR}/${PN}${PV%${PV#?}}/site_${PN}/${PV}" \
 -Darchname=${CHOST} \
 -Duseshrplib

make 'miniperl' || exit
make DESTDIR='/install' install-strip || exit

cd "${INSTALL_DIR}/" || exit

post-inst-perm

RMLIST="$(pkg-rmlist)" pkg-rm

post-rm
pkg-rm-empty
pre-perm
