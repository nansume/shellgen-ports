#!/bin/sh
# 2021-2022
# Date: 2023-10-15 08:00 UTC - Log: near to compat-posix

test "x${USER}" != 'xroot' || return 0

mkdir -pm '0755' ${INSTALL_DIR}/bin/
cp -vnul ${WORKDIR}/src/${PKGNAME}?* "${INSTALL_DIR}"/bin/${PKGNAME}
