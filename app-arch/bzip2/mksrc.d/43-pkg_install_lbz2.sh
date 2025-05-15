#!/bin/sh
# Copyright (C) 2021-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-15 08:00 UTC - Log: near to compat-posix, no-posix: local VAR

local OLD_UMASK="$(umask)"

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

umask u=rwx,g=rx,o=rx

mkdir -pm 0755 "${INSTALL_DIR}/${LIB_DIR}/" "${INSTALL_DIR}/${DPREFIX#/}/include/"
#mv -vn lib/ ${LIB_DIR}/
cp -vnul "libbz2.so.${PV}" ${INSTALL_DIR}/${LIB_DIR}/
ln -sf "libbz2.so.${PV}" ${INSTALL_DIR}/${LIB_DIR}/"libbz2.so.${PV%.*}"
ln -sf "libbz2.so.${PV}" ${INSTALL_DIR}/${LIB_DIR}/"libbz2.so"  # fix: not found -lbz2
#cp -vlf ${WORKDIR}/${PN}-shared bin/${PN}
#cp -vlf ${WORKDIR}/${PN}-shared bin/bunzip2
#cp -vlf ${WORKDIR}/${PN}-shared bin/bzcat
#ln -sf bzdiff bin/bzcmp
#ln -sf bzgrep bin/bzegrep
#ln -sf bzgrep bin/bzfgrep
#ln -sf bzmore bin/bzless
cp -nl "bzlib.h" ${INSTALL_DIR}/${DPREFIX#/}/include/

umask ${OLD_UMASK}
