#!/bin/sh

test "x${USER}" != 'xroot' || return 0

test -d "${WORKDIR}" || exit
cd "${WORKDIR}/"

mkdir -pm '0755' ${INSTALL_DIR}/usr/share/${PN}/
