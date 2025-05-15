#!/bin/sh

local EXIT='exit'; local DPREFIX=${DPREFIX#/}; local PATH=${PATH}
local CERTSCONF; local CERTSDIR; local ETCCERTSDIR; local X; local S

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

PATH="${PATH}:${INSTALL_DIR}/bin:${INSTALL_DIR}/sbin"
CERTSCONF="${INSTALL_DIR}/etc/ca-certificates.conf"
CERTSDIR="${INSTALL_DIR}/${DPREFIX}/share/${PN}/mozilla"
ETCCERTSDIR="${INSTALL_DIR}/etc/ssl/certs"


test -d "${INSTALL_DIR}" || ${EXIT}
cd "${INSTALL_DIR}/"

rm -- "${CERTSDIR:?}/NetLock_Arany_"*".crt"  # no correct name

mkdir -pm '0755' ${ETCCERTSDIR}/ ${CERTSDIR}/
&>>"${CERTSCONF:?}"

# https://github.com/kisslinux/repo/commit/6397fb2cc8c0ead51f4d384aed1177529f1cf8c6
# openssl:Error: <rehash> is an invalid command.
# Fix with libressl
sed -i 's|ssl rehash|ssl certhash|' sbin/update-ca-certificates

update-ca-certificates -v -d --certsconf ${CERTSCONF} --certsdir ${CERTSDIR} --etccertsdir ${ETCCERTSDIR}

cd ${ETCCERTSDIR}/
for X in *; do
  S=$(ls -l "${X}")
  S=${S#* -> }
  case ${S} in "${INSTALL_DIR}/"*);; *) continue;; esac
  ln -sf "${S#$INSTALL_DIR}" "${X}"
done

rm -- "${CERTSCONF}"
