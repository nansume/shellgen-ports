#!/bin/bash
# Copyright (C) 2021-2022 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html


# not required: replace: `e2fsprogs` --> `libuuid`
[[ -d ${WORKDIR} ]] || return 0
cd "${WORKDIR}/"

((UID)) || return 0
declare PN='uuid' S D

mkdir -pm '0755' ${INSTALL_DIR}/${DPREFIX#/}/include/${PN}/
#mv -vf etc/mke2fs.conf.new etc/mke2fs.conf

#cp -nlf ${PN}.h ${INSTALL_DIR}/${DPREFIX#/}/include/${PN}/
cp -nlf "lib/${PN}/${PN}.h.in" ${INSTALL_DIR}/${DPREFIX#/}/include/${PN}/${PN}.h
cp -nlf "lib/${PN}/${PN}_types.h" ${INSTALL_DIR}/${DPREFIX#/}/include/${PN}/