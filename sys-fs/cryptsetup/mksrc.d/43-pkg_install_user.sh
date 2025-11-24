#!/bin/sh
# rename {prog}.static --> {prog}

USE="${USE} +static"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

if use 'static'; then
  for PROG in "${ED}"/sbin/*.static; do
    rm -v -- ${PROG%.static}
    mv -v -n ${PROG} ${PROG%.static}
  done
  printf %s\\n "Install fix: ${PN}"
fi
